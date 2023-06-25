import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/change_password/change_password.dart';
import 'package:dima_app/screens/edit_profile/edit_profile.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/theme_manager.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/profile_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Settings",
        upRightActions: [
          MyIconButton(
            margin: const EdgeInsets.only(
                right: LayoutConstants.kModalHorizontalPadding),
            icon:
                Icon(Icons.logout, color: Theme.of(context).primaryColorLight),
            onTap: () async {
              await Provider.of<FirebaseUser>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          controller: ScrollController(),
          children: [
            Container(height: LayoutConstants.kPaddingFromCreate),
            const ProfileData(),
            ContainerShadow(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Dark mode",
                    ),
                    value: Preferences.getBool('isDark'),
                    onChanged: (newValue) {
                      setState(() {
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
                    value: Preferences.getBool('is24Hour'),
                    onChanged: (bool newValue) {
                      setState(() {
                        Provider.of<ClockManager>(context, listen: false)
                            .toggleClock(newValue);
                        // Preferences.setBool('is24Hour', value);
                      });
                    },
                    secondary: const Icon(Icons.access_time),
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Push notifications",
                    ),
                    value:
                        Provider.of<FirebaseNotification>(context, listen: true)
                            .isPush,
                    onChanged: (bool newValue) async {
                      LoadingOverlay.show(context);
                      if (newValue) {
                        String curUid =
                            Provider.of<FirebaseUser>(context, listen: false)
                                .user!
                                .uid;
                        await Provider.of<FirebaseNotification>(context,
                                listen: false)
                            .subscribeToTopic(curUid);
                      } else {
                        await Provider.of<FirebaseNotification>(context,
                                listen: false)
                            .deleteToken();
                      }
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.hide(context);
                      setState(() {});
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit profile"),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () async {
                      Stream<UserModel> stream =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .getCurrentUserStream();
                      UserModel userData = await stream.first;
                      Widget newScreen = EditProfileScreen(userData: userData);
                      // ignore: use_build_context_synchronously
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
                      Widget newScreen = const ChangePasswordScreen();
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Sign Out"),
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
                ],
              ),
            ),
            Container(height: LayoutConstants.kPaddingFromCreate),
          ],
        ),
      ),
    );
  }
}
