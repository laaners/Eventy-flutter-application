import 'package:dima_app/screens/profile/profile_info.dart';
import 'package:dima_app/screens/profile/profile_settings.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Profile",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
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
