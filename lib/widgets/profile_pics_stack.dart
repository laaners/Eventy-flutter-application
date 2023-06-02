import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../screens/error/error.dart';

class ProfilePicsStack extends StatelessWidget {
  final double radius;
  final double offset;
  final List<String> uids;
  const ProfilePicsStack({
    super.key,
    required this.radius,
    required this.offset,
    required this.uids,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: Provider.of<FirebaseUser>(context, listen: false)
          .getUsersDataFromList(uids: uids),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<UserModel>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          Future.microtask(() {
            Navigator.of(context).pop();
            Navigator.push(
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
        List<UserModel> users = snapshot.data!;
        return SizedBox(
          height: radius * 2,
          width: (radius * 2 - offset) * 3 + offset,
          child: Stack(
            children: [
              ...users.mapIndexed((index, user) {
                return Positioned(
                  left: (radius * 2 - offset) * index,
                  child: ProfilePic(
                    userData: user,
                    loading: false,
                    radius: radius,
                  ),
                );
              }).toList(),
              if (users.isEmpty)
                StreamBuilder(
                  stream: Provider.of<FirebaseUser>(context, listen: false)
                      .getCurrentUserStream(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<UserModel> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingLogo(extWidth: 30);
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const LogInScreen();
                    }
                    UserModel userData = snapshot.data!;
                    return Positioned(
                      left: 0,
                      child: ProfilePic(
                        userData: userData,
                        loading: false,
                        radius: radius,
                      ),
                    );
                  },
                ),
              for (var index = users.length; index < 2; index++)
                Positioned(
                  left: (radius * 2 - offset) * index,
                  child: Container(width: radius * 2),
                )
            ],
          ),
        );
      },
    );
  }
}
