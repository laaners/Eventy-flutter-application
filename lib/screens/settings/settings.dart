import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/change_password/change_password.dart';
import 'package:dima_app/screens/edit_profile/edit_profile.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/theme_manager.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Settings", upRightActions: []),
      body: ResponsiveWrapper(
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text(
                "Dark mode",
              ),
              value: Preferences.getBool('isDark'),
              onChanged: (newValue) {
                Provider.of<ThemeManager>(context, listen: false)
                    .toggleTheme(newValue);
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            SwitchListTile(
              title: const Text(
                "24-hour clock",
              ),
              value: Preferences.getBool('is24Hour'),
              onChanged: (bool value) {
                setState(() {
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
                    .signOut();
              },
            ),
            // Delete account not implemented yet
            // ListTile(
            //   leading: const Icon(Icons.delete_forever),
            //   title: const Text("Delete Account"),
            //   trailing: const Icon(Icons.navigate_next),
            //   onTap: () {
            //     showDialog<String>(
            //         context: context,
            //         builder: (BuildContext context) => DeleteDialog());
            //   },
            // ),
            Container(height: LayoutConstants.kPaddingFromCreate),
          ],
        ),
      ),
    );
  }
}
