import 'package:dima_app/providers/preferences.dart';
import 'package:dima_app/screens/profile/edit_profile.dart';
import 'package:dima_app/screens/profile/delete_dialog.dart';
import 'package:dima_app/themes/theme_manager.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../server/firebase_user.dart';
import 'change_password.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationEnabled = Preferences.getBool('isPush');
  bool _darkModeEnabled = Preferences.getBool('isDark');
  bool _24HourEnabled = Preferences.getBool('is24Hour');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Settings", upRightActions: []),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text(
              "Push notifications",
            ),
            value: _pushNotificationEnabled,
            onChanged: (bool value) {
              setState(() {
                _pushNotificationEnabled = value;
                Preferences.setBool('isPush', value);
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
          SwitchListTile(
            title: const Text(
              "24-hour clock",
            ),
            value: _24HourEnabled,
            onChanged: (bool value) {
              setState(() {
                _24HourEnabled = value;
                Preferences.setBool('is24Hour', value);
              });
            },
            secondary: const Icon(Icons.access_time),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit profile"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Widget newScreen = const EditProfileScreen();
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => newScreen,
                ),
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
            title: const Text("Sign Out"),
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
      ),
    );
  }
}
