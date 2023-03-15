import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile/profile_pic.dart';
import '../server/firebase_user.dart';

class UserList extends StatefulWidget {
  final List<String> users;
  final double height;

  const UserList({super.key, required this.users, required this.height});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late ScrollController controller;
  late int usersToLoad;
  List<String> usersData = [];

  @override
  void initState() {
    usersToLoad = widget.height ~/ 80.round();
    controller = ScrollController()..addListener(_scrollListener);
    initUsersData(0,
        widget.users.length < usersToLoad ? widget.users.length : usersToLoad);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    usersData = [];
    super.dispose();
  }

  void initUsersData(int start, int end) {
    setState(() {
      for (int i = start; i < end; i++) {
        usersData.add(widget.users[i]);
      }
    });
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500) {
      if (usersData.length < widget.users.length - usersToLoad) {
        initUsersData(usersData.length, usersData.length + usersToLoad);
      } else if (usersData.length < widget.users.length) {
        initUsersData(usersData.length, widget.users.length);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.users.isNotEmpty
        ? Scrollbar(
            child: ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                return UserTile(
                  userUid: widget.users[index],
                );
              },
              itemCount: widget.users.length,
            ),
          )
        : const Center(
            child: Text("empty"),
          );
  }
}

class UserTile extends StatelessWidget {
  final String userUid;
  const UserTile({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserCollection?>(
      future: Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, userUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<UserCollection?> snapshot,
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
              radius: 30,
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
                    builder: (context) => ViewProfileScreen(userData: userData),
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
