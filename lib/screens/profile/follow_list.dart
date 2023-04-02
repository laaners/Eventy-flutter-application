import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';

import '../../widgets/my_app_bar.dart';
import '../../widgets/user_list.dart';

class FollowListScreen extends StatelessWidget {
  final List<String> users;
  final String title;
  const FollowListScreen({
    super.key,
    required this.users,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: title,
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: UserList(
          users: users,
        ),
      ),
    );
  }
}
