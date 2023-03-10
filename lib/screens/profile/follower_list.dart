import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../widgets/my_app_bar.dart';
import '../../widgets/user_list.dart';

class FollowerListScreen extends StatelessWidget {
  final List<String> users;
  const FollowerListScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Followers"),
      body: UserList(
        users: users,
      ),
    );
  }
}
// UserList(          users:              Provider.of<FirebaseFollow>(context, listen: false).followersUid)