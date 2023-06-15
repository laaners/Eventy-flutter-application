import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/widgets/profile_info.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Profile",
        upRightActions: [],
      ),
      body: ResponsiveWrapper(
        child: StreamBuilder(
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
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  ScreenTransition(
                    builder: (context) => ErrorScreen(
                      errorMsg: snapshot.error.toString(),
                    ),
                  ),
                );
              });
              return Container();
            }
            UserModel userDataSnapshot = snapshot.data!;
            return ListView(
              children: [
                const SizedBox(height: LayoutConstants.kHeight),
                ProfilePic(
                  userData: userDataSnapshot,
                  loading: false,
                  radius: LayoutConstants.kProfilePicRadius,
                ),
                const SizedBox(height: LayoutConstants.kHeight),
                ProfileInfo(userData: userDataSnapshot),
                Container(height: LayoutConstants.kPaddingFromCreate),
              ],
            );
          },
        ),
      ),
    );
  }
}
