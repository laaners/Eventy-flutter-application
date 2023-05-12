import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/debug.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/widgets/profile_info.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<UserModel> _stream;

  @override
  void initState() {
    _stream = Provider.of<FirebaseUser>(context, listen: false)
        .getCurrentUserStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Home',
        upRightActions: [],
      ),
      body: StreamBuilder(
          stream: _stream,
          builder: (
            BuildContext context,
            AsyncSnapshot<UserModel> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingSpinner();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const LogInScreen();
            }
            UserModel userData = snapshot.data!;
            return ResponsiveWrapper(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.kHorizontalPadding,
                ),
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
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const SizedBox(height: LayoutConstants.kHeight),
                          ProfileInfo(userData: userData),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: LayoutConstants.kHeightSmall),
                  const Divider(height: LayoutConstants.kDividerHeight),
                  // const EventPanel(),
                  Container(height: LayoutConstants.kPaddingFromCreate),
                ],
              ),
            );
          }),
    );
  }
}

/*
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
*/