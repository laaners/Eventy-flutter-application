import 'package:dima_app/screens/profile/edit_profile.dart';
import 'package:dima_app/screens/profile/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_switch.dart';
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
            // This is called when the user toggles the switch.
            setState(() {
              _pushNotificationEnabled = value;
            });
          },
          secondary: const Icon(Icons.notifications),
        ),
        Consumer<FirebaseUser>(builder: (context, valueUser, _) {
          return SwitchListTile(
            title: const Text(
              "Dark mode",
            ),
            value: !valueUser.userData!.isLightMode,
            onChanged: (bool value) {
              // This is called when the user toggles the switch.
              Provider.of<ThemeSwitch>(context, listen: false)
                  .changeTheme(context);
            },
            secondary: const Icon(Icons.dark_mode),
          );
        }),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text("Delete Account"),
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
