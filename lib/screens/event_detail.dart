import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Event Detail",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => const EventDetailScreen(),
              ),
            );
          },
          child: const Text("TO EVENT DETAIL"),
        ),
      ),
    );
  }
}
