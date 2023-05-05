import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/event_detail/index.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../server/tables/event_collection.dart';

class EventList extends StatefulWidget {
  final String userUid;

  const EventList({
    super.key,
    required this.userUid,
  });

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  int _refresh = 1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FirebaseEvent>(context, listen: false)
          .getOtherUserPublicOrInvitedEvents(context, widget.userUid),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        if (!snapshot.hasData) {
          return Container(
            child: const Text("empty"),
          );
        }
        var eventsData = snapshot.data!;
        print(eventsData);
        return ListView(
          children: eventsData
              .map(
                (e) => EventTile(
                  eventData: e["eventDetails"] as EventCollection,
                  invited: e["invited"] as bool,
                  refreshParent: () {
                    setState(() {
                      _refresh += 1;
                    });
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class EventTile extends StatelessWidget {
  final EventCollection eventData;
  final bool invited;
  final VoidCallback refreshParent;
  const EventTile({
    super.key,
    required this.eventData,
    required this.invited,
    required this.refreshParent,
  });

  @override
  Widget build(BuildContext context) {
    String eventId = "${eventData.eventName}_${eventData.organizerUid}";
    return SizedBox(
      height: 80,
      child: ListTile(
        /*
        trailing: Text(
            "public: ${eventData.public.toString()}, canInvite: ${eventData.canInvite.toString()}, invited: ${invited.toString()}"),
        */
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.place),
        ),
        title: Text(eventData.eventName),
        subtitle: Text(eventData.organizerUid),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          // if not invited and is a public event, add invite
          if (!invited && eventData.public) {
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: eventId,
              inviteeId: curUid,
            );
            refreshParent();
          }

          Widget newScreen = EventDetailScreen(eventId: eventId);
          // ignore: use_build_context_synchronously
          var ris = await Navigator.of(context, rootNavigator: false).push(
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
        },
      ),
    );
  }
}
