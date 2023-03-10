import 'package:dima_app/screens/profile/follower_list.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/user_list.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    initFollow();
    super.initState();
  }

  void initFollow() async {
    String uid =
        Provider.of<FirebaseUser>(context, listen: false).userData!["uid"];
    await Provider.of<FirebaseFollow>(context, listen: false)
        .getFollowers(context, uid);
    // ignore: use_build_context_synchronously
    await Provider.of<FirebaseFollow>(context, listen: false)
        .getFollowing(context, uid);
  }

  @override
  Column build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: const ChangeImage(),
        ),
        Center(
          child: Consumer<FirebaseUser>(
            builder: (context, value, child) {
              return Text(
                  "${value.userData!["name"]} ${value.userData!["surname"]}");
            },
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<FirebaseFollow>(
                builder: (context, value, child) {
                  print("before followers");
                  print(value.followersUid);
                  return TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FollowerListScreen(
                                    users: value.followersUid,
                                  )),
                        );
                      },
                      child: Text("${value.followersUid.length} followers"));
                },
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const FollowerListScreen()),
              //     );
              //   },
              //   // await Provider.of<PostgresMethods>(context, listen: false).method(params);
              //   child: Consumer<FirebaseFollow>(
              //     builder: (context, value, child) {
              //       print("before followers");
              //       print(value.followersUid);
              //       return Text("${value.followersUid.length} followers");
              //     },
              //   ),
              // ),
              const VerticalDivider(
                thickness: 2,
                color: Colors.grey,
              ),
              TextButton(
                onPressed: () {
                  // add transition to list of following
                },
                // await Provider.of<PostgresMethods>(context, listen: false).method(params);
                child: Consumer<FirebaseFollow>(
                  builder: (context, value, child) {
                    return Text("${value.followingUid.length} following");
                  },
                ),
              ),
            ],
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
          title: const Text("Sign out"),
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
