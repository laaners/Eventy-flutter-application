import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../server/firebase_user.dart';

class UserList extends StatefulWidget {
  final List<String> users;

  const UserList({super.key, required this.users});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late ScrollController controller;
  List<Map<String, dynamic>> usersData = [];

  @override
  void initState() {
    initUsersData(0, widget.users.length < 10 ? widget.users.length : 10);
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
          ? Center(
              child: Text("empty"),
            )
          : ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                print(usersData.length);
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
      usersData.add(userData);
    }
  }

  void _scrollListener() {
    print(controller.position.extentAfter);
    if (controller.position.extentAfter < 500) {
      setState(() {
        usersData
            .addAll(List.generate(42, (index) => {"name": 'Inserted $index'}));
      });
    }
  }
}

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserTile({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown.shade800,
          child: const Text('AH'),
        ),
        title: Text("$userData['name'] $userData['surname']"),
        subtitle: Text("$userData['username']"),
      ),
    );
  }
}
