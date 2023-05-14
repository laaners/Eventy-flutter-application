import 'package:dima_app/models/event_location_model.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'event_location_tile.dart';

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
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 0, left: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ...eventLocationDetails.events.map((event) {
                return EventLocationTile(eventPreview: event);
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
                .deletePoll(context: context, pollId: eventId);
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
