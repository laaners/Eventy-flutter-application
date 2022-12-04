import 'package:dima_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);
  final String title;
  const MyAppBar(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<ThemeSwitch>(context, listen: false).changeTheme();
          },
          child: Icon(
            Icons.dark_mode,
            color: Provider.of<ThemeSwitch>(context).themeData.iconTheme.color,
          ),
        ),
      ],
    );
  }
}
