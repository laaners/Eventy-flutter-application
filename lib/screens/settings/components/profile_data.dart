import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/debug.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/profile_info.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileData extends StatelessWidget {
  const ProfileData({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<FirebaseUser>(context, listen: false)
          .getCurrentUserStream(),
      builder: (
        BuildContext context,
        AsyncSnapshot<UserModel> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const LogInScreen();
        }
        UserModel userData = snapshot.data!;
        return Column(
          children: [
            ProfilePic(
              userData: userData,
              loading: false,
              radius: LayoutConstants.kProfilePicRadius,
            ),
            const SizedBox(height: LayoutConstants.kHeight),
            ProfileInfo(userData: userData),
          ],
        );
      },
    );
  }
}
