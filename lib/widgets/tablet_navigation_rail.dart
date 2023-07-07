import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/main.dart';
import 'package:dima_app/models/notification_model.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabletNavigationRail extends StatelessWidget {
  const TabletNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    int tabIndex =
        Provider.of<CupertinoTabController>(context, listen: true).index;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: NavigationRail(
            selectedIndex: tabIndex >= 2 ? tabIndex - 1 : tabIndex,
            onDestinationSelected: (index) {
              if (index >= 2) {
                Provider.of<CupertinoTabController>(context, listen: false)
                    .index = index + 1;
                return;
              }
              Provider.of<CupertinoTabController>(context, listen: false)
                  .index = index;
            },
            labelType: NavigationRailLabelType.all,
            leading: CreatePollEventButton(),
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.group),
                label: Text('Groups'),
              ),
              NavigationRailDestination(
                icon: StreamBuilder(
                    stream: Provider.of<FirebaseNotification>(context,
                            listen: false)
                        .getUserNotificationsSnapshot(uid: curUid),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return const Icon(Icons.notifications);
                      }
                      NotificationModel notificationModel =
                          NotificationModel.fromMap(
                              snapshot.data!.data() as Map<String, dynamic>);
                      List<PollEventNotification> notifications =
                          notificationModel.notifications;
                      bool anyNotRead = notifications
                          .any((notification) => !notification.isRead);
                      return Stack(
                        children: [
                          if (anyNotRead)
                            Positioned(
                              right: 0.0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          const Icon(Icons.notifications),
                        ],
                      );
                    }),
                label: Text('Notifications'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
