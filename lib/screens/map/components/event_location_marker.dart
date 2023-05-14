// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/event_location_model.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventLocationMarker extends StatelessWidget {
  final EventLocationModel eventLocationDetails;
  final VoidCallback findNearbyEvents;
  const EventLocationMarker({
    super.key,
    required this.eventLocationDetails,
    required this.findNearbyEvents,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = eventLocationDetails.site
        .replaceFirst("${eventLocationDetails.site.split(", ")[0]}, ", "");
    return GestureDetector(
      onTap: () async {
        var ris = await MyModal.show(
          context: context,
          child: Column(
            children: [
              if (subtitle != eventLocationDetails.site)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ...eventLocationDetails.events.map((event) {
                String startInfo = DateFormat(
                        Preferences.getBool('is24Hour') ? "HH:mm" : "hh:mm a")
                    .format(DateFormatter.string2DateTime(
                        "${event.date} ${event.start}:00"));
                String endInfo = DateFormat(
                        Preferences.getBool('is24Hour') ? "HH:mm" : "hh:mm a")
                    .format(DateFormatter.string2DateTime(
                        "${event.date} ${event.end}:00"));
                return Builder(builder: (context) {
                  return PollEventTile(
                    locationBanner: event.locationBanner,
                    descTop: "${event.date}: $startInfo - $endInfo",
                    descMiddle: event.eventName,
                    descBottom:
                        "${event.public ? "Public" : "Private"} event, you are ${event.invited ? "partecipating" : "not partecipating"}",
                    trailing: event.invited
                        ? const Icon(Icons.arrow_forward_ios_rounded)
                        : const Icon(Icons.login),
                    onTap: () async {
                      var curUid =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .user!
                              .uid;
                      // if not invited and is a public event, add invite
                      if (!event.invited && event.public) {
                        bool confirmJoin =
                            await MyAlertDialog.showAlertConfirmCancel(
                          context: context,
                          title: "Join this event?",
                          content:
                              "\"${event.eventName}\" is public, you can join this event",
                          trueButtonText: "Join",
                        );
                        if (!confirmJoin) return;
                        LoadingOverlay.show(context);
                        await Provider.of<FirebasePollEventInvite>(context,
                                listen: false)
                            .createPollEventInvite(
                          pollEventId: event.eventId,
                          inviteeId: curUid,
                        );
                        LoadingOverlay.hide(context);
                      }
                      Navigator.pop(context, event.eventId);
                    },
                  );
                });
              }).toList()
            ],
          ),
          heightFactor: 0.85,
          doneCancelMode: true,
          onDone: () {},
          title: eventLocationDetails.site.split(",")[0],
        );
        if (ris != null) {
          String eventId = ris;
          findNearbyEvents();
          var curUid =
              // ignore: use_build_context_synchronously
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          Widget newScreen = PollEventScreen(pollEventId: eventId);
          // ignore: use_build_context_synchronously
          ris = await Navigator.of(context, rootNavigator: false).push(
            ScreenTransition(
              builder: (context) => newScreen,
            ),
          );
          if (ris == "delete_Event_$curUid") {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebasePollEvent>(context, listen: false)
                .deletePollEvent(context: context, pollId: eventId);
            /*
            */
          }
        }
      },
      child: const Icon(
        Icons.location_pin,
        color: Colors.blue,
        size: 40,
      ),
    );
  }
}
