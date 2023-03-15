import 'package:dima_app/screens/event_create/index.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/my_app_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Events"),
      body: ListView(
        children: [
          const Center(
            child: Text(
              "EVENTS",
              style: TextStyle(fontSize: 40),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => const PollDetailScreen(
                    pollId: "gg_HB6d3gyBuwbG5RY1qK5bvqwdIkb2",
                  ),
                ),
              );
            },
            child: const Text("TO POLL DETAIL (WITH TABBAR)"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => const EventCreateScreen(),
                ),
              );
            },
            child: const Text("TO EVENT CREATE"),
          ),
        ],
      ),
    );
  }
}
