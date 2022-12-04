import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Groups"),
      body: ListView(
        children: const [
          Center(
            child: Text(
              "GROUPS",
              style: TextStyle(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}
