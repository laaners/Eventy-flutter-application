import 'package:flutter/material.dart';
import 'user_tile.dart';

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
                return UserTileFromUid(
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
