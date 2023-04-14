import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_pic.dart';
import '../server/firebase_user.dart';

class UserList extends StatelessWidget {
  final List<String> users;
  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return users.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              return UserTile(
                userUid: users[index],
              );
            },
            itemCount: users.length,
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
  Future<UserCollection?>? _future;

  @override
  initState() {
    super.initState();
    _future = Provider.of<FirebaseUser>(context, listen: false)
        .getUserData(context, widget.userUid);
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
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
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
        if (!snapshot.hasData) {
          return Container();
        }
        UserCollection userData = snapshot.data!;
        return SizedBox(
          height: 80,
          child: ListTile(
            leading: ProfilePic(
              loading: false,
              userData: userData,
              radius: 25,
            ),
            title: Text("${userData.name} ${userData.surname}"),
            subtitle: Text(userData.username),
            onTap: () {
              var curUid =
                  Provider.of<FirebaseUser>(context, listen: false).user!.uid;
              if (curUid == userData.uid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewProfileScreen(profileUserData: userData),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
