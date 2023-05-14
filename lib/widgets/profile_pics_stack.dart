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

class ProfilePicsStack extends StatefulWidget {
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
  State<ProfilePicsStack> createState() => _ProfilePicsStackState();
}

class _ProfilePicsStackState extends State<ProfilePicsStack> {
  Future<List<UserModel>>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUsersDataFromList(uids: widget.uids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _future,
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
          height: widget.radius * 2,
          width: (widget.radius * 2 - widget.offset) * 3 + widget.offset,
          child: Stack(
            children: [
              ...users.mapIndexed((index, user) {
                return Positioned(
                  left: (widget.radius * 2 - widget.offset) * index,
                  child: ProfilePic(
                    userData: user,
                    loading: false,
                    radius: widget.radius,
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
                      return const LoadingLogo();
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
                        radius: widget.radius,
                      ),
                    );
                  },
                ),
              for (var index = users.length; index < 2; index++)
                Positioned(
                  left: (widget.radius * 2 - widget.offset) * index,
                  child: Container(width: widget.radius * 2),
                )
            ],
          ),
        );
      },
    );
  }
}
