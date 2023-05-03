import 'package:dima_app/screens/debug.dart';
import 'package:dima_app/screens/profile/follow_buttons.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import 'profile/profile_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserCollection userData;

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<FirebaseUser>(context, listen: false).userData!;
    return Scaffold(
      appBar: const MyAppBar(
        title: 'HOME',
        upRightActions: [],
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: LayoutConstants.kHorizontalPadding),
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DebugScreen(),
                  ),
                );
              },
              child: const Text("Debug page"),
            ),
            Row(
              children: [
                ProfilePic(
                  userData: userData,
                  loading: false,
                  radius: LayoutConstants.kProfilePicRadius,
                ),
                Column(
                  children: [
                    const SizedBox(height: LayoutConstants.kHeight),
                    ProfileInfo(userData: userData),
                    const SizedBox(height: LayoutConstants.kHeight),
                    FollowButtons(
                      userData: userData,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(
              height: LayoutConstants.kDividerHeight,
            ),
          ]),
    );
  }
}
