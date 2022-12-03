import 'package:dima_app/themes/palette.dart';
import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  const MyTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Palette.greyColor,
          ),
        ),
      ),
      child: TabBar(
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.black,
        indicatorColor: Colors.transparent,
        tabs: [
          Tab(
            icon: Icon(Icons.home),
            text: "Home",
            iconMargin: EdgeInsets.all(0),
          ),
          Tab(
            icon: Icon(Icons.event),
            text: "Events",
            iconMargin: EdgeInsets.all(0),
          ),
          Tab(
            icon: Icon(Icons.groups),
            text: "Groups",
            iconMargin: EdgeInsets.all(0),
          ),
          Tab(
            icon: Icon(Icons.account_circle),
            text: "Profile",
            iconMargin: EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }
}
