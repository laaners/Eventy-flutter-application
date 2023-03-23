import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FirebaseEvent>(context, listen: false)
          .getUserEvents(context, widget.userUid),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context).pop();
            Navigator.push(
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
        if (!snapshot.hasData) {
          return Container();
        }
        var eventsData = snapshot.data!;
        return Column(
          children: [
            // todo
            ...eventsData.map((e) => EventTile(eventData: e)).toList(),
          ],
        );
      },
    );
  }
}

class EventTile extends StatelessWidget {
  final EventCollection eventData;

  const EventTile({
    super.key,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.place),
        ),
        title: Text(eventData.eventName),
        subtitle: Text(eventData.organizerUid),
        onTap: () {},
      ),
    );
  }
}
