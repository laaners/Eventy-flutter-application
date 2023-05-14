import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/material.dart';

void showUserDialog({
  required BuildContext context,
  required UserModel user,
}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(user.username),
      content: Row(
        children: [
          ProfilePic(userData: user, loading: false, radius: 45),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              "${user.name}\n${user.surname}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
