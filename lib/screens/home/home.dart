import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/debug.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/home/components/poll_event_list.dart';
import 'package:dima_app/screens/home/components/profile_data.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/profile_info.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Stream<UserModel> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _stream = Provider.of<FirebaseUser>(context, listen: false)
        .getCurrentUserStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const TabbarSwitcher(
      labels: ["By you", "Invited"],
      listSticky: ProfileData(),
      stickyHeight: 250,
      appBarTitle: "Home",
      upRightActions: [],
      tabbars: [
        PollEventList(),
        Text("ok"),
      ],
    );
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
            return const LoadingLogo();
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
                        // ProfileInfo(userData: userData),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: LayoutConstants.kHeightSmall),
                Divider(
                  height: LayoutConstants.kDividerHeight,
                  color: Theme.of(context).dividerColor,
                ),
                // const EventPanel(),
                Container(height: LayoutConstants.kPaddingFromCreate),
              ],
            ),
          );
        },
      ),
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
  late Future<List<PollEventModel>> _future;
  @override
  void initState() {
    super.initState();
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;

    _future = Provider.of<FirebasePollEvent>(context, listen: false)
        .getUserOrganizedPollsEvents(uid: userUid);
  }

  @override
  Widget build(BuildContext context) {
    // events here
    return FutureBuilder(
      future: _future,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<PollEventModel>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          Future.microtask(() {
            Navigator.of(context, rootNavigator: false).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        List<PollEventModel> events = snapshot.data!;
        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: _sections.length,
          itemBuilder: (BuildContext context, int index) => ExpansionTile(
            leading: const Icon(Icons.drag_indicator),
            key: Key('$index'),
            title: Text(
              _sections[index],
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            children: [
              ...events.map((event) {
                return PollEventTile(
                  locationBanner: event.locations[0].icon,
                  descTop: event.dates.toString(),
                  onTap: () async {
                    // ignore: use_build_context_synchronously
                    String pollEventId =
                        "${event.pollEventName}_${event.organizerUid}";
                    var curUid =
                        // ignore: use_build_context_synchronously
                        Provider.of<FirebaseUser>(context, listen: false)
                            .user!
                            .uid;
                    Widget newScreen =
                        PollEventScreen(pollEventId: pollEventId);
                    // ignore: use_build_context_synchronously
                    var ris =
                        await Navigator.of(context, rootNavigator: false).push(
                      ScreenTransition(
                        builder: (context) => newScreen,
                      ),
                    );
                    if (ris == "delete_poll_$curUid") {
                      // ignore: use_build_context_synchronously
                      await Provider.of<FirebasePollEvent>(context,
                              listen: false)
                          .deletePollEvent(
                        context: context,
                        pollId: pollEventId,
                      );
                    }
                  },
                  descMiddle: event.pollEventName,
                  descBottom: event.locations[0].site.isEmpty
                      ? "No link provided"
                      : event.locations[0].site,
                );
              }).toList()
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
      },
    );
  }
}
*/