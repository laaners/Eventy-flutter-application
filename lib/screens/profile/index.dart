import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_switch.dart';
import 'change_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Profile"),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Profile",
              style: TextStyle(fontSize: 28),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: const [
              ProfileInfo(),
              Divider(
                height: 30,
              ),
              ProfileSettings(),
            ]),
          ),
          //const Spacer(),
        ],
      ),
    );
  }
}

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String _name = "Jeff Bridge";
  int _friendsNumber = 46;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: const ChangeImage(),
        ),
        Center(
          child: Text(
            _name,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            border: Border(),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: TextButton(
            onPressed: () {
              // add transition to list of friends
            },
            child: Text('$_friendsNumber friends'),
          ),
        )
      ],
    );
  }
}

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
            // add transition to EditProfileScreen
          },
        ),
        ListTile(
          leading: const Icon(Icons.password),
          title: const Text("Change password"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            // add change password transition
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Sing out"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {
            // add transition to initial screen (LogInScreen?)
          },
        ),
      ],
    );
  }
}


// todo: add ProfileViewScreen