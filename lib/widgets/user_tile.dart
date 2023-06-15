import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_logo.dart';
import 'profile_pic.dart';
import 'screen_transition.dart';
import 'show_user_dialog.dart';

class UserTileFromData extends StatelessWidget {
  final UserModel userData;
  const UserTileFromData({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: ProfilePic(
          loading: false,
          userData: userData,
          radius: 30,
        ),
        title: Text("${userData.name} ${userData.surname}"),
        subtitle: Text(userData.username),
        onTap: () {
          showUserDialog(context: context, user: userData);
        },
      ),
    );
  }
}

class UserTileFromUid extends StatefulWidget {
  final String userUid;
  const UserTileFromUid({super.key, required this.userUid});

  @override
  State<UserTileFromUid> createState() => _UserTileFromUidState();
}

class _UserTileFromUidState extends State<UserTileFromUid> {
  Future<UserModel?>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUserData(uid: widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError) {
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
        if (!snapshot.hasData) {
          return Container();
        }
        UserModel userData = snapshot.data!;
        return UserTileFromData(userData: userData);
      },
    );
  }
}
