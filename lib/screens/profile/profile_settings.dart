import 'package:dima_app/screens/profile/edit_profile.dart';
import 'package:dima_app/screens/profile/delete_dialog.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../server/firebase_user.dart';
import 'change_password.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _pushNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            "Push notifications",
          ),
          value: _pushNotificationEnabled,
          onChanged: (bool value) {
            setState(() {
              _pushNotificationEnabled = value;
            });
          },
          secondary: const Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: const Text(
            "Dark mode",
          ),
          value: _darkModeEnabled,
          onChanged: (newValue) {
            setState(() {
              _darkModeEnabled = newValue;
              Provider.of<ThemeManager>(context, listen: false)
                  .toggleTheme(newValue);
            });
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text("Edit profile"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.password),
          title: const Text("Change password"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Sing Out"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () async {
            await Provider.of<FirebaseUser>(context, listen: false)
                .signOut(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text("Delete Account"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => DeleteDialog());
          },
        ),
      ],
    );
  }
}
