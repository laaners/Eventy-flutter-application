import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poll_event_list_body.dart';

class PollEventListInvited extends StatefulWidget {
  const PollEventListInvited({super.key});

  @override
  State<PollEventListInvited> createState() => _PollEventListInvitedState();
}

class _PollEventListInvitedState extends State<PollEventListInvited>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebasePollEventInvite>(context, listen: false)
          .getAllPollEventInviteSnapshot(uid: curUid),
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
          return Expanded(
            child: ListView(
              controller: ScrollController(),
              children: const [EmptyList(emptyMsg: "No polls or events")],
            ),
          );
        }
        List<PollEventInviteModel> invites = snapshot.data!.docs
            .map((e) =>
                PollEventInviteModel.fromMap(e.data() as Map<String, dynamic>))
            .toList();
        // filter out invites where curUid is not organizer:
        // a pollEventId is name_organizerUid, so:
        invites = invites.where((invite) {
          try {
            String organizerUid = invite.pollEventId.split("_")[1];
            return organizerUid != curUid;
          } on RangeError catch (e) {
            print(e.toString());
            return false;
          }
        }).toList();
        return StreamBuilder(
          stream: Provider.of<FirebasePollEvent>(context, listen: false)
              .getUserInvitedPollsEventsSnapshot(
            pollEventIds: invites.map((e) => e.pollEventId).toList(),
          ),
          builder: (
            BuildContext context,
            var snapshot,
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
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Expanded(
                child: ListView(
                  controller: ScrollController(),
                  children: const [EmptyList(emptyMsg: "No polls or events")],
                ),
              );
            }
            List<PollEventModel> events = snapshot.data!
                .map((e) => PollEventModel.firebaseDocToObj(
                    e.data() as Map<String, dynamic>))
                .toList();
            return PollEventListBody(events: events);
          },
        );
      },
    );
  }
}
