import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/firebase_Event.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/Event_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventSearchByName extends StatelessWidget {
  const EventSearchByName({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await showSearch<String>(
          context: context,
          delegate: CustomDelegate(),
        );
      },
      child: const Icon(
        Icons.search,
      ),
    );
  }
}

class CustomDelegate extends SearchDelegate<String> {
  List<PollEventCollection> eventsData = [];

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? Container()
        : FutureBuilder(
            future: Provider.of<FirebasePollEvent>(context, listen: false)
                .searchEventsByName(context, query),
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
              eventsData = snapshot.data!;
              return ResponsiveWrapper(
                child: ListView.builder(
                  itemCount: eventsData.length,
                  itemBuilder: (_, i) {
                    var event = eventsData[i];
                    return EventTileSearch(
                      eventData: event,
                    );
                  },
                ),
              );
            },
          );
  }
}

class EventTileSearch extends StatelessWidget {
  final PollEventCollection eventData;
  const EventTileSearch({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Text(eventData.pollEventName);
  }
}