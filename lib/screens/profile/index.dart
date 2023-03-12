import 'package:dima_app/screens/profile/follow_list.dart';
import 'package:dima_app/screens/profile/profile_info.dart';
import 'package:dima_app/screens/profile/profile_settings.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_switch.dart';
import 'change_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Profile"),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(children: [
              ProfileInfo(
                userData:
                    Provider.of<FirebaseUser>(context, listen: false).userData,
              ),
              const Divider(
                height: 30,
              ),
              const ProfileSettings(),
            ]),
          ),
        ],
      ),
    );
  }
}
