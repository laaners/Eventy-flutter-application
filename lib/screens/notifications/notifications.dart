import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/notification_model.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/notifications/components/notification_tile.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/empty_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Scaffold(
      appBar: MyAppBar(
        title: "Notifications",
        upRightActions: [
          MyIconButton(
            icon: Icon(Icons.clear_all,
                color: Theme.of(context).primaryColorLight),
            onTap: () async {
              bool ris = await MyAlertDialog.showAlertConfirmCancel(
                context: context,
                title: "Delete all notifications",
                content:
                    "This action cannot be undone, delete all the notifications?",
                trueButtonText: "Confirm",
              );
              if (ris) {
                // ignore: use_build_context_synchronously
                await Provider.of<FirebaseNotification>(context, listen: false)
                    .deleteAllNotifications(context: context);
              }
            },
          ),
          MyIconButton(
            margin: const EdgeInsets.only(
                right: LayoutConstants.kModalHorizontalPadding),
            icon:
                Icon(Icons.refresh, color: Theme.of(context).primaryColorLight),
            onTap: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Scrollbar(
          child: StreamBuilder(
              stream: Provider.of<FirebaseNotification>(context, listen: false)
                  .getUserNotificationsSnapshot(uid: curUid),
              builder: (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingLogo();
                }
                if (snapshot.hasError) {
                  Future.microtask(() {
                    Navigator.of(context, rootNavigator: false).pushReplacement(
                      ScreenTransition(
                        builder: (context) => ErrorScreen(
                          errorMsg: snapshot.error.toString(),
                        ),
                      ),
                    );
                  });
                  return Container();
                }
                if (!snapshot.data!.exists) {
                  return ListView(
                    controller: ScrollController(),
                    shrinkWrap: true,
                    children: const [
                      SizedBox(height: 30),
                      EmptyList(
                        emptyMsg: "No notifications",
                      ),
                    ],
                  );
                }
                NotificationModel notificationModel = NotificationModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>);
                List<PollEventNotification> notifications =
                    notificationModel.notifications;
                notifications
                    .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                return notifications.isEmpty
                    ? ListView(
                        controller: ScrollController(),
                        shrinkWrap: true,
                        children: const [
                          SizedBox(height: 30),
                          EmptyList(
                            emptyMsg: "No notifications",
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        controller: ScrollController(),
                        itemCount: notifications.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == notifications.length) {
                            return Container(
                                height: LayoutConstants.kPaddingFromCreate);
                          }
                          PollEventNotification notification =
                              notifications[index];
                          return NotificationTile(
                            notification: notification,
                          );
                        },
                      );
              }),
        ),
      ),
    );
  }
}
