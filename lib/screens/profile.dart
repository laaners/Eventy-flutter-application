import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Profile"),
      body: ListView(
        children: const [
          Center(
            child: Text(
              "PROFILE",
              style: TextStyle(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}
