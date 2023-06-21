import 'package:dima_app/screens/home/components/poll_event_list_by_you.dart';
import 'package:dima_app/screens/home/components/poll_event_list_invited.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbarSwitcher(
      labels: const ["By you", "Invited"],
      stickyHeight: 0,
      appBarTitle: "Home",
      alwaysShowTitle: true,
      upRightActions: [MyAppBar.createEvent(context)],
      tabbars: const [
        PollEventListByYou(),
        PollEventListInvited(),
      ],
    );
  }
}
