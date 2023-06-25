import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/poll_event_methods.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationTile extends StatefulWidget {
  final PollEventNotification notification;
  const NotificationTile({super.key, required this.notification});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  Future<UserModel?>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUserData(uid: widget.notification.organizerUid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MyListTile(
              title: widget.notification.title,
              subtitle: widget.notification.body,
              subtitleMaxLines: 2,
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                ScreenTransition(
                  builder: (context) => ErrorScreen(
                    errorMsg: snapshot.error.toString(),
                  ),
                ),
              );
            });
            return Container();
          }
          UserModel userData = snapshot.data!;
          DateTime timestamp =
              DateFormatter.string2DateTime(widget.notification.timestamp);
          Duration differenceDuration = DateTime.now().difference(timestamp);

          String suffix = "d";
          int difference = differenceDuration.inDays;

          suffix = difference < 1 ? "h" : suffix;
          difference = difference < 1 ? differenceDuration.inHours : difference;

          suffix = difference < 1 ? "m" : suffix;
          difference =
              difference < 1 ? differenceDuration.inMinutes : difference;

          suffix = difference < 1 ? "s" : suffix;
          difference =
              difference < 1 ? differenceDuration.inSeconds : difference;

          difference = difference < 0 ? -difference : difference;

          return Container(
            decoration: BoxDecoration(
              color: widget.notification.isRead
                  ? null
                  : Theme.of(context).highlightColor,
            ),
            child: MyListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.kHorizontalPadding, vertical: 5),
              title: widget.notification.title,
              subtitle: widget.notification.body,
              subtitleMaxLines: 3,
              leading: ProfilePicFromData(userData: userData),
              trailing: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await Provider.of<FirebaseNotification>(context,
                            listen: false)
                        .deleteNotification(
                      context: context,
                      notification: widget.notification,
                    );
                    /*
                    if (!widget.notification.isRead) {
                      await Provider.of<FirebaseNotification>(context,
                              listen: false)
                          .updateNotification(
                        context: context,
                        notification: widget.notification,
                      );
                    }
                    */
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(difference.toString() + suffix),
                      const Icon(Icons.delete),
                    ],
                  ),
                ),
              ),
              onTap: () async {
                if (!widget.notification.isRead) {
                  await Provider.of<FirebaseNotification>(context,
                          listen: false)
                      .updateNotification(
                    context: context,
                    notification: widget.notification,
                  );
                }
                Widget newScreen = PollEventScreen(
                    pollEventId: widget.notification.pollEventId);
                var ris =
                    // ignore: use_build_context_synchronously
                    await Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );

                // ignore: use_build_context_synchronously
                await PollEventUserMethods.optionsRisManager(
                  context: context,
                  pollEventId: widget.notification.pollEventId,
                  ris: ris,
                );
              },
            ),
          );
        });
  }
}
