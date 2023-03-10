import 'package:dima_app/screens/event_create/index.dart';
import 'package:dima_app/screens/event_detail.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/screens/profile/change_image.dart';
import 'package:flutter/material.dart';

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
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => const PollDetailScreen(
                    organizerUid: "IrI8s7a6WeVUgF3fAYd99YHdnqh2",
                    pollName: "a",
                  ),
                ),
              );
            },
            child: const Text("TO POLL DETAIL (WITH TABBAR)"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                ScreenTransition(
                  builder: (context) => const PollDetailScreen(
                    organizerUid: "IrI8s7a6WeVUgF3fAYd99YHdnqh2",
                    pollName: "a",
                  ),
                ),
              );
            },
            child: const Text("TO EVENT DETAIL (NO TABBAR)"),
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
