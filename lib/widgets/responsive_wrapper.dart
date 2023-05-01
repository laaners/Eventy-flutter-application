import 'package:collection/collection.dart';
import 'package:dima_app/screens/profile/profile_settings.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_spinner.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isAuthenticated =
        Provider.of<FirebaseUser>(context, listen: true).user != null;
    UserCollection? userData =
        Provider.of<FirebaseUser>(context, listen: true).userData;
    bool hasUserData = userData != null;
    return SafeArea(
      child: DelayWidget(
        child: isAuthenticated &&
                hasUserData &&
                MediaQuery.of(context).orientation == Orientation.landscape &&
                true
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
                                  userData: userData,
                                  loading: false,
                                  radius: 90,
                                ),
                              ),
                              Text('@${userData.username}'),
                              Text("${userData.name} ${userData.surname}"),
                            ],
                          ),
                          ...[
                            {"label": "Home", "icon": Icons.home},
                            {"label": "Events", "icon": Icons.event},
                            {"label": "Profile", "icon": Icons.account_circle},
                          ].mapIndexed((index, obj) {
                            int activeIndex =
                                Provider.of<CupertinoTabController>(context,
                                        listen: true)
                                    .index;
                            return ListTile(
                              leading: IconTheme(
                                data: index == activeIndex
                                    ? Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .selectedIconTheme!
                                    : Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedIconTheme!,
                                child: Icon(
                                  obj["icon"] as IconData,
                                ),
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
                  constraints: const BoxConstraints(maxWidth: 6000),
                  child: Container(
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}
