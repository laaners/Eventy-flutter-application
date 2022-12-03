import 'package:dima_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/my_tab_bar.dart';
import 'events.dart';
import 'home.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Event Detail"),
          actions: [
            TextButton(
              onPressed: () {
                Provider.of<ThemeSwitch>(context, listen: false).changeTheme();
              },
              child: const Text(
                "DARK/LIGHT MODE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            EventsScreen(),
          ],
        ),
        bottomNavigationBar: const MyTabBar(),
      ),
    );
  }
}
