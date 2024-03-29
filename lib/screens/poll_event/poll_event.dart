import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_detail/poll_detail.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollEventScreen extends StatefulWidget {
  final String pollEventId;

  const PollEventScreen({
    super.key,
    required this.pollEventId,
  });

  @override
  State<PollEventScreen> createState() => _PollEventScreenState();
}

class _PollEventScreenState extends State<PollEventScreen>
    with AutomaticKeepAliveClientMixin {
  bool _refresh = true;

  @override
  bool get wantKeepAlive => true;

  void refreshPollDetail() {
    setState(() {
      _refresh = !_refresh;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebasePollEventInvite>(context, listen: false)
          .getPollEventInviteSnapshot(pollId: widget.pollEventId, uid: curUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
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
        if (!snapshot.data!.exists) {
          Future.microtask(() {
            Navigator.of(context, rootNavigator: false).pushReplacement(
              ScreenTransition(
                builder: (context) => const ErrorScreen(
                  errorMsg: "The organizer limited your access to the event",
                ),
              ),
            );
          });
          return Container();
        }
        return StreamBuilder(
            stream: Provider.of<FirebasePollEvent>(context, listen: false)
                .getPollDataSnapshot(pollId: widget.pollEventId),
            builder: (
              BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingLogo();
              }
              if (snapshot.hasError || !snapshot.data!.exists) {
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

              /*
              */
              // check if it is closed or the deadline was reached
              Map<String, dynamic> tmp =
                  snapshot.data!.data() as Map<String, dynamic>;
              String localDate = DateFormatter.dateTime2String(
                  (tmp["deadline"] as Timestamp).toDate());
              localDate = DateFormatter.toLocalString(localDate);
              bool isClosed = tmp["isClosed"] ||
                  DateFormatter.string2DateTime(localDate)
                      .isBefore(DateTime.now());
              if (isClosed && !tmp["isClosed"]) {
                // close the event on db
                Provider.of<FirebasePollEvent>(context, listen: false)
                    .closePoll(pollId: widget.pollEventId, context: context);
              }

              return FutureBuilder<Map<String, dynamic>?>(
                future: Provider.of<FirebasePollEvent>(context, listen: false)
                    .getPollDataAndInvites(
                  context: context,
                  pollEventId: widget.pollEventId,
                ),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>?> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: ResponsiveWrapper(child: LoadingLogo()),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    Future.microtask(() {
                      Navigator.of(context, rootNavigator: false)
                          .pushReplacement(
                        ScreenTransition(
                          builder: (context) => ErrorScreen(
                            errorMsg: snapshot.error.toString(),
                          ),
                        ),
                      );
                    });
                    return Container();
                  }
                  PollEventModel pollData = snapshot.data!["data"];

                  List<PollEventInviteModel> pollInvites =
                      snapshot.data!["invites"];
                  List<VoteLocationModel> votesLocations =
                      snapshot.data!["locations"];
                  votesLocations.sort((a, b) =>
                      b.getPositiveVotes().length -
                      a.getPositiveVotes().length);
                  List<VoteDateModel> votesDates = snapshot.data!["dates"];
                  votesDates.sort((a, b) =>
                      b.getPositiveVotes().length -
                      a.getPositiveVotes().length);

                  return PollDetailScreen(
                    pollId: widget.pollEventId,
                    pollData: pollData,
                    pollInvites: pollInvites,
                    votesLocations: votesLocations,
                    votesDates: votesDates,
                    refreshPollDetail: refreshPollDetail,
                  );
                  // return const SettingsScreen();
                },
              );
            });
      },
    );
  }
}
