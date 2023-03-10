import 'package:dima_app/screens/profile/view_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../server/firebase_user.dart';

class UserList extends StatefulWidget {
  final List<String> users;
  final double height;

  const UserList({super.key, required this.users, required this.height});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late ScrollController controller;
  late int usersToLoad;
  List<Map<String, dynamic>> usersData = [];

  @override
  void initState() {
    usersToLoad = widget.height ~/ 80.round();
    initUsersData(0,
        widget.users.length < usersToLoad ? widget.users.length : usersToLoad);
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  initUsersData(int start, int end) async {
    for (int i = start; i < end; i++) {
      var userData = await Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, widget.users[i]) as Map<String, dynamic>;
      setState(() {
        usersData.add(userData);
      });
    }
  }

  void _scrollListener() {
    print(controller.position.extentAfter);
    if (controller.position.extentAfter < 500) {
      if (usersData.length < widget.users.length - usersToLoad) {
        initUsersData(usersData.length, usersData.length + usersToLoad);
      } else if (usersData.length < widget.users.length) {
        initUsersData(usersData.length, widget.users.length);
      }
    }
  }
}

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserTile({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.brown.shade800,
          child: Text("${userData['name'][0]}${userData['surname'][0]}"),
        ),
        title: Text("${userData['name']} ${userData['surname']}"),
        subtitle: Text("${userData['username']}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileScreen(userData: userData)),
          );
        },
      ),
    );
  }
}
