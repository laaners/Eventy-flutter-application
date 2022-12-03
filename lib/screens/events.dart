import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Center(
          child: Text(
            "EVENTS",
            style: TextStyle(fontSize: 40),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/event_detail');
          },
          child: const Text("TO EVENT DETAIL"),
        ),
      ],
    );
  }
}
