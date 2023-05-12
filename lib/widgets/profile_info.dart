import 'package:dima_app/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final UserModel userData;
  const ProfileInfo({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '@${userData.username + userData.username}',
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${userData.name} ${userData.surname}",
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
