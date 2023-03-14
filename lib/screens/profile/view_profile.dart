import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/event_poll_switch.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatelessWidget {
  final UserCollection userData;

  const ViewProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(userData.username),
      body: ListView(children: [
        ProfileInfo(
          userData: userData,
        ),
        const Divider(
          height: 30,
        ),
        EventPollSwitch(userUid: userData.uid),
      ]),
    );
  }
}
