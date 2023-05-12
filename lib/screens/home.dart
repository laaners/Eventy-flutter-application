import 'package:dima_app/screens/debug.dart';
import 'package:dima_app/screens/event_detail/index.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/screens/profile/follow_buttons.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
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
  // even sections
  final List<String> _sections = ["Invited", "My Events", "My Followers"];

  @override
  Widget build(BuildContext context) {
    // events here
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user?.uid;
    final Future<List<PollEventCollection>> myEvents =
        Provider.of<FirebaseEvent>(context, listen: false)
            .getUserEvents(context, userUid!);

    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: _sections.length,
      itemBuilder: (BuildContext context, int index) => ExpansionTile(
        leading: const Icon(Icons.drag_indicator),
        key: Key('$index'),
        title: Text(
          _sections[index],
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        children: [
          ListTile(title: Text('EventTile ${_sections[index]}')),
          ListTile(title: Text('EventTile ${_sections[index]}')),
        ],
      ),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final String section = _sections.removeAt(oldIndex);
          _sections.insert(newIndex, section);
        });
      },
    );
  }
}

class EventTile extends StatefulWidget {
  final PollEventCollection event;

  const EventTile({super.key, required this.event});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.event),
      title: Text(widget.event.pollEventName),
      subtitle: const Text("Location"),
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
    ;
  }
}
