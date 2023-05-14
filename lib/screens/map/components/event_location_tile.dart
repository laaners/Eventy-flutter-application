import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/event_location_preview.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventLocationTile extends StatelessWidget {
  final EventLocationPreview eventPreview;
  const EventLocationTile({super.key, required this.eventPreview});

  @override
  Widget build(BuildContext context) {
    String startInfo =
        DateFormat(Preferences.getBool('is24Hour') ? "HH:mm" : "hh:mm a")
            .format(DateFormatter.string2DateTime(
                eventPreview.date + " " + eventPreview.start + ":00"));
    String endInfo =
        DateFormat(Preferences.getBool('is24Hour') ? "HH:mm" : "hh:mm a")
            .format(DateFormatter.string2DateTime(
                eventPreview.date + " " + eventPreview.end + ":00"));
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: LocationIcons.icons[eventPreview.locationBanner] != null
              ? Icon(LocationIcons.icons[eventPreview.locationBanner])
              : ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    "https://images.ygoprodeck.com/images/cards_cropped/42502956.jpg",
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress != null) {
                        return const Icon(Icons.place);
                      } else {
                        return child;
                      }
                      /*
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                        */
                    },
                  ),
                ),
        ),
        trailing: eventPreview.invited
            ? const Icon(Icons.arrow_forward_ios_rounded)
            : const Icon(Icons.login),
        /*
        */

        title: Text(
          eventPreview.eventName,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${eventPreview.public ? "Public" : "Private"} event, you are ${eventPreview.invited ? "partecipating" : "not partecipating"}",
            ),
            Text("${eventPreview.date}: $startInfo - $endInfo")
          ],
        ),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          // if not invited and is a public event, add invite
          if (!eventPreview.invited && eventPreview.public) {
            bool confirmJoin = await MyAlertDialog.showAlertConfirmCancel(
              context: context,
              title: "Join this event?",
              content:
                  "\"${eventPreview.eventName}\" is public, you can join this event",
              trueButtonText: "Join",
            );
            if (!confirmJoin) return;
            LoadingOverlay.show(context);
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              pollEventId: eventPreview.eventId,
              inviteeId: curUid,
            );
            LoadingOverlay.hide(context);
          }
          Navigator.pop(context, eventPreview.eventId);
        },
      ),
    );
  }
}
