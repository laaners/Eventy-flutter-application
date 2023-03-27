import 'package:dima_app/screens/profile/edit_profile.dart';
import 'package:dima_app/widgets/dialog_delete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_switch.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _pushNotificationEnabled = true;
  bool _darkModeEnabled = false;

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
            // This is called when the user toggles the switch.
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
          onChanged: (bool value) {
            // This is called when the user toggles the switch.
            setState(() {
              _darkModeEnabled = value;
              Provider.of<ThemeSwitch>(context, listen: false).changeTheme();
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
          leading: const Icon(Icons.logout),
          title: const Text("Sign out"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            // TODO: add transition to initial screen (LogInScreen?)
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text("Delete Account"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            // TODO: add transition to initial screen (LogInScreen?)
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => DeleteDialog());
          },
        ),
      ],
    );
  }
}
