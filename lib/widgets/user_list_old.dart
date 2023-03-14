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
  List<UserCollection> usersData = [];

  @override
  void initState() {
    usersToLoad = widget.height ~/ 80.round();
    controller = ScrollController()..addListener(_scrollListener);
    // initUsersData(0,widget.users.length < usersToLoad ? widget.users.length : usersToLoad);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    usersData = [];
    super.dispose();
  }

  Future<List<UserCollection>> initUsersData(int start, int end) async {
    List<UserCollection> ris = [];
    for (int i = start; i < end; i++) {
      var userData = await Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, widget.users[i]);
      ris.add(userData!);
    }
    return ris;
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
    return FutureBuilder<List<UserCollection>>(
      future: initUsersData(
          0,
          widget.users.length < usersToLoad
              ? widget.users.length
              : usersToLoad),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<UserCollection>> snapshot,
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
        print(snapshot.data![0].uid);
        return Scrollbar(
          child: snapshot.data!.isEmpty
              ? const Center(
                  child: Text("empty"),
                )
              : ListView.builder(
                  controller: controller,
                  itemBuilder: (context, index) {
                    return UserTile(
                      userData: snapshot.data![index],
                    );
                  },
                  itemCount: usersData.length,
                ),
        );
      },
    );
    return Scrollbar(
      child: usersData.isEmpty
          ? const Center(
              child: Text("empty"),
            )
          : ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                return UserTile(
                  userData: usersData[index],
                );
              },
              itemCount: usersData.length,
            ),
    );
  }
}

class UserTile extends StatelessWidget {
  final UserCollection userData;

  const UserTile({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
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
  }
}
