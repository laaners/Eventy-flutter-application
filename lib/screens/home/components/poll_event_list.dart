import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollEventList extends StatelessWidget {
  const PollEventList({super.key});

  @override
  Widget build(BuildContext context) {
    final userUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebasePollEvent>(context, listen: false)
          .getUserOrganizedPollsEventsSnapshot(uid: userUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingLogo();
        }
        if (snapshot.hasError) {
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyList(emptyMsg: "No polls or events");
        }
        List<PollEventModel> events = snapshot.data!.docs
            .map((e) => PollEventModel.firebaseDocToObj(
                e.data() as Map<String, dynamic>))
            .toList();
        return ListView.builder(
          itemCount: events.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == events.length) {
              return Container(height: LayoutConstants.kPaddingFromCreate);
            }
            PollEventModel event = events[index];
            bool isClosed = event.isClosed ||
                DateFormatter.string2DateTime(event.deadline)
                    .isBefore(DateTime.now());

            return PollEventTile(
              pollEvent: event,
              bgColor: isClosed ? Theme.of(context).primaryColorLight : null,
              locationBanner: event.locations[0].icon,
              descTop:
                  isClosed ? "Closed poll" : "Poll due to ${event.deadline}",
              onTap: () async {
                // ignore: use_build_context_synchronously
                String pollEventId =
                    "${event.pollEventName}_${event.organizerUid}";
                var curUid =
                    // ignore: use_build_context_synchronously
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;
                Widget newScreen = PollEventScreen(pollEventId: pollEventId);
                // ignore: use_build_context_synchronously
                var ris =
                    await Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );
                if (ris == "delete_poll_$curUid") {
                  // ignore: use_build_context_synchronously
                  await Provider.of<FirebasePollEvent>(context, listen: false)
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
          },
        );
      },
    );
  }
}
