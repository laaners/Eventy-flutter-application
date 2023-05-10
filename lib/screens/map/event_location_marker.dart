import 'package:dima_app/screens/map/event_location_tile.dart';
import 'package:dima_app/screens/map/index.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/event_location_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventLocationMarker extends StatelessWidget {
  final EventLocationCollection eventLocationDetails;
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
                  margin: const EdgeInsets.only(bottom: 0, top: 0, left: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ...eventLocationDetails.events.map((event) {
                return EventLocationTile(
                  eventId: event["eventId"],
                  eventName: event["eventName"],
                  invited: event["invited"] as bool,
                  public: event["public"] as bool,
                  locationBanner: event["locationBanner"],
                );
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
            await Provider.of<FirebaseEvent>(context, listen: false)
                .deleteEvent(
              context: context,
              eventId: eventId,
              showOutcome: true,
            );
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
