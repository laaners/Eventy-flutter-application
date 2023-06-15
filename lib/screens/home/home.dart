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