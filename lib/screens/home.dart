import 'package:dima_app/screens/debug.dart';
import 'package:dima_app/screens/event_detail/index.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/screens/profile/follow_buttons.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile/profile_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserCollection userData;

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<FirebaseUser>(context, listen: false).userData!;
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Home',
        upRightActions: [],
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: LayoutConstants.kHorizontalPadding),
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  ScreenTransition(
                    builder: (context) => const DebugScreen(),
                  ),
                );
              },
              child: const Text("Debug page"),
            ),
            Row(
              children: [
                ProfilePic(
                  userData: userData,
                  loading: false,
                  radius: LayoutConstants.kProfilePicRadius,
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    const SizedBox(height: LayoutConstants.kHeight),
                    ProfileInfo(userData: userData),
                    const SizedBox(height: LayoutConstants.kHeightSmall),
                    FollowButtons(
                      userData: userData,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: LayoutConstants.kHeightSmall,
            ),
            const Divider(
              height: LayoutConstants.kDividerHeight,
            ),
            const EventPanel(),
          ]),
    );
  }
}

/// ListTile that takes an Event object displays its info
class EventTile extends StatelessWidget {
  const EventTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.event),
      title: const Text("Event Name"),
      subtitle: const Text("Event Location"),
      // visibility on/off
      trailing: const Icon(Icons.visibility),
      onTap: () {
        Widget newScreen = const PollEventScreen(pollEventId: '');
        Navigator.of(context).push(
          ScreenTransition(
            builder: (context) => newScreen,
          ),
        );
      },
    );
  }
}

/// Generate a list of Event object based on ad hoc query
List<EventTile> generateEvents(int numberOfEvents) {
  return List<EventTile>.generate(numberOfEvents, (int index) {
    return const EventTile();
  });
}

// get event based on ad hoc query
List<String> generateItems(int numberOfItems) {
  return List<String>.generate(numberOfItems, (int index) {
    return 'Panel $index';
  });
}

class EventPanel extends StatefulWidget {
  const EventPanel({super.key});

  @override
  State<EventPanel> createState() => _EventPanelState();
}

class _EventPanelState extends State<EventPanel> {
  // main
  //final List<Item> _sections = generateItems(20);
  final List<int> _items = List<int>.generate(50, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) => ExpansionTile(
        leading: const Icon(Icons.drag_indicator),
        key: Key('$index'),
        title: Text(
          'Item ${_items[index]}',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        children: [
          ListTile(title: Text('EventTile ${_items[index]}')),
          ListTile(title: Text('EventTile ${_items[index]}')),
        ],
      ),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
    );
  }
}
