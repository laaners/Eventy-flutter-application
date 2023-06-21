import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_logo.dart';
import 'profile_pic.dart';
import 'screen_transition.dart';
import 'show_user_dialog.dart';

class UserTileFromData extends StatelessWidget {
  final UserModel userData;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  const UserTileFromData({
    super.key,
    required this.userData,
    this.trailing,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return MyListTile(
      title: userData.username,
      subtitle: "${userData.name} ${userData.surname}",
      contentPadding: contentPadding,
      leading: ProfilePic(
        loading: false,
        userData: userData,
        radius: 30,
      ),
      trailing: trailing,
      onTap: () {
        showUserDialog(context: context, user: userData);
      },
    );
  }
}

class UserTileFromUid extends StatefulWidget {
  final String userUid;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  const UserTileFromUid({
    super.key,
    required this.userUid,
    this.trailing,
    this.contentPadding,
  });

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
        return UserTileFromData(
          userData: userData,
          trailing: widget.trailing,
          contentPadding: widget.contentPadding,
        );
      },
    );
  }
}
