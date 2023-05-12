import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventLocationTile extends StatelessWidget {
  final String eventId;
  final String eventName;
  final bool public;
  final bool invited;
  final String locationBanner;
  const EventLocationTile({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.public,
    required this.invited,
    required this.locationBanner,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: LocationIcons.icons[locationBanner] != null
              ? Icon(LocationIcons.icons[locationBanner])
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
        trailing: invited
            ? const Icon(Icons.arrow_forward_ios_rounded)
            : const Icon(Icons.login),
        /*
        */

        title: Text(
          eventName,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${public ? "Public" : "Private"} event, you are ${invited ? "partecipating" : "not partecipating"}",
        ),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          // if not invited and is a public event, add invite
          if (!invited && public) {
            bool confirmJoin = await MyAlertDialog.showAlertConfirmCancel(
              context: context,
              title: "Join this event?",
              content: "\"$eventName\" is public, you can join this event",
              trueButtonText: "Join",
            );
            if (!confirmJoin) return;
            LoadingOverlay.show(context);
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: eventId,
              inviteeId: curUid,
            );
            LoadingOverlay.hide(context);
          }
          Navigator.pop(context, eventId);
        },
      ),
    );
  }
}
