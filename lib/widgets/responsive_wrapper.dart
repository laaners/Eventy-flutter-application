import 'package:collection/collection.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DelayWidget(
        child:
            MediaQuery.of(context).orientation == Orientation.landscape && false
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
                      /*
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
                  */
                    ],
                  )
                : Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: child,
                      ),
                    ),
                  ),
      ),
    );
  }
}
