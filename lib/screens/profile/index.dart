import 'package:dima_app/screens/profile/profile_info.dart';
import 'package:dima_app/screens/profile/profile_settings.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/themes/layout_constants.dart';
import '../../server/tables/user_collection.dart';

import '../../widgets/profile_pic.dart';
import 'follow_buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserCollection? userData;
  bool _refresh = true;

  @override
  void initState() {
    userData = Provider.of<FirebaseUser>(context, listen: false).userData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refresh = !_refresh;
        });
        return;
      },
      child: Scaffold(
        appBar: const MyAppBar(
          title: "Profile",
          upRightActions: [],
        ),
        body: ResponsiveWrapper(
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: LayoutConstants.kHeight),
                  ProfilePic(
                    userData: userData,
                    loading: false,
                    radius: LayoutConstants.kProfilePicRadius,
                  ),
                  const SizedBox(height: LayoutConstants.kHeight),
                  ProfileInfo(userData: userData),
                  const SizedBox(height: LayoutConstants.kHeight),
                  FollowButtons(userData: userData),
                  const Divider(height: LayoutConstants.kDividerHeight),
                  const ProfileSettings(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
