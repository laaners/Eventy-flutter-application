import 'package:collection/collection.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/screens/profile/profile_settings.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<FirebaseUser>(
        builder: (context, value, _) {
          return value.user != null &&
                  MediaQuery.of(context).orientation == Orientation.landscape
              ? Stack(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 4 * 3,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: child,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 4),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: ProfilePic(
                                    userData: value.userData,
                                    loading: false,
                                    radius: 90,
                                  ),
                                ),
                                Text('@${value.userData!.username}'),
                                Text(
                                    "${value.userData!.name} ${value.userData!.surname}"),
                              ],
                            ),
                            ...[
                              {"label": "Home", "icon": Icons.home},
                              {"label": "Events", "icon": Icons.event},
                              {
                                "label": "Profile",
                                "icon": Icons.account_circle
                              },
                            ].mapIndexed((index, obj) {
                              int activeIndex =
                                  Provider.of<CupertinoTabController>(context,
                                          listen: true)
                                      .index;
                              return ListTile(
                                leading: Icon(
                                  obj["icon"] as IconData,
                                  color: activeIndex == index
                                      ? Provider.of<ThemeSwitch>(context)
                                          .themeData
                                          .primaryColor
                                      : null,
                                ),
                                title: Text(obj["label"] as String),
                                // trailing: const Icon(Icons.navigate_next),
                                onTap: () {
                                  Provider.of<CupertinoTabController>(context,
                                          listen: false)
                                      .index = index;
                                },
                              );
                            }).toList(),
                            const Divider(),
                            const ProfileSettings(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      child: child,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
