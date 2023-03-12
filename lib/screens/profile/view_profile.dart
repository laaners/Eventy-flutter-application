import 'package:dima_app/widgets/event_poll_switch.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ViewProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("${userData['username']}"),
      body: ListView(children: [
        ProfileInfo(
          userData: userData,
        ),
        const Divider(
          height: 30,
        ),
        const EventPollSwitch(),
      ]),
    );
  }
}
