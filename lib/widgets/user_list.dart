import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/show_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_pic.dart';
import 'screen_transition.dart';

class UserList extends StatelessWidget {
  final List<String> users;
  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return users.isNotEmpty
        ? Scrollbar(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserTile(
                  userUid: users[index],
                );
              },
            ),
          )
        : const Center(
            child: Text("empty"),
          );
  }
}

class UserTile extends StatefulWidget {
  final String userUid;
  const UserTile({super.key, required this.userUid});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
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
        return SizedBox(
          height: 80,
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: ProfilePic(
              loading: false,
              userData: userData,
              radius: 25,
            ),
            title: Text("${userData.name} ${userData.surname}"),
            subtitle: Text(userData.username),
            onTap: () {
              showUserDialog(context: context, user: userData);
            },
          ),
        );
      },
    );
  }
}
