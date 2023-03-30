import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/event_list.dart';
import 'package:dima_app/widgets/event_poll_switch.dart';
import 'package:dima_app/widgets/lists_switcher.dart';
import 'package:dima_app/widgets/poll_list.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatefulWidget {
  final UserCollection userData;
  const ViewProfileScreen({super.key, required this.userData});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  int _refresh = 1;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refresh = 0;
        });
        return;
      },
      child: Scaffold(
        appBar: MyAppBar(
          title: widget.userData.name,
          upRightActions: [MyAppBar.SearchAction(context)],
        ),
        body: ListView(children: [
          ProfileInfo(
            userData: widget.userData,
          ),
          const Divider(
            height: 30,
          ),
          ListsSwitcher(
            labels: const ["Events", "Polls"],
            lists: [
              EventList(userUid: widget.userData.uid),
              PollList(userUid: widget.userData.uid)
            ],
          ),
          // EventPollSwitch(userUid: userData.uid),
        ]),
      ),
    );
  }
}
