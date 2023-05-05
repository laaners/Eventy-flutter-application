import 'package:dima_app/screens/event_create/index.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/event_detail/index.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/my_app_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Events",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () async {
                // ignore: use_build_context_synchronously
                String pollId =
                    "Event 1 of UsernameId14_0DmBO8Fw0ofrK9RbXIO4dYlEIg03";
                var curUid =
                    // ignore: use_build_context_synchronously
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;
                Widget newScreen = PollEventScreen(pollEventId: pollId);
                // ignore: use_build_context_synchronously
                var ris =
                    await Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );
                if (ris == "delete_poll_$curUid") {
                  // ignore: use_build_context_synchronously
                  await Provider.of<FirebasePoll>(context, listen: false)
                      .deletePoll(
                    context: context,
                    pollId: pollId,
                  );
                }
              },
              child: const Text("TO POLL DETAIL (WITH TABBAR)"),
            ),
            ElevatedButton(
              onPressed: () async {
                var curUid =
                    // ignore: use_build_context_synchronously
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;

                // the result from pop is the poll id
                final pollId =
                    await Navigator.of(context, rootNavigator: true).push(
                  ScreenTransition(
                    builder: (context) => const EventCreateScreen(),
                  ),
                );
                if (pollId != null) {
                  Widget newScreen = PollEventScreen(pollEventId: pollId);
                  // ignore: use_build_context_synchronously
                  var ris =
                      await Navigator.of(context, rootNavigator: false).push(
                    ScreenTransition(
                      builder: (context) => newScreen,
                    ),
                  );
                  if (ris == "delete_poll_$curUid") {
                    // ignore: use_build_context_synchronously
                    await Provider.of<FirebasePoll>(context, listen: false)
                        .closePoll(
                      context: context,
                      pollId: pollId,
                    );
                  }
                }
              },
              child:
                  const Text("IMPORTANT: poll create, push to poll directly"),
            ),
            MyButton(
              text: "IMPORTANT: no inv poll, admin deletes",
              onPressed: () async {
                String pollId = "Event 0_0DmBO8Fw0ofrK9RbXIO4dYlEIg03";
                Widget newScreen = PollEventScreen(pollEventId: pollId);
                var ris =
                    await Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );
                var curUid =
                    // ignore: use_build_context_synchronously
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;
                if (ris == "delete_poll_$curUid") {
                  // ignore: use_build_context_synchronously
                  await Provider.of<FirebasePoll>(context, listen: false)
                      .closePoll(
                    context: context,
                    pollId: pollId,
                  );
                }
              },
            ),
            MyButton(
              text: "no inv event",
              onPressed: () {
                const newScreen = EventDetailScreen(
                  eventId:
                      "Event 0 of UsernameId0_5bbooaayEaS9nIjJtYDvWGB7Xiv2",
                );
                Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                LoadingOverlay.show(context);
                /*
                await showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Scaffold(
                      body: ResponsiveWrapper(
                        child: Container(
                            // margin: const EdgeInsets.only(top: 15, bottom: 15),
                            child: GmapFromCoor(
                          address: "ok",
                          lat: 50,
                          lon: 50,
                        )),
                      ),
                    ),
                  ),
                );
                */
              },
              child: const Text("map test"),
            ),
          ],
        ),
      ),
    );
  }
}
