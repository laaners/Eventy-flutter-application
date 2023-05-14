import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_detail/poll_detail.dart';
import 'package:dima_app/screens/settings/settings.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
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
  Future<Map<String, dynamic>?>? _future;
  bool _refresh = true;

  Future<Map<String, dynamic>?> getPollDataAndInvites(
      BuildContext context) async {
    try {
      PollEventModel? pollData =
          await Provider.of<FirebasePollEvent>(context, listen: false)
              .getPollData(id: widget.pollEventId);
      if (pollData == null) return null;

      // deadline reached, close poll
      // check if it is closed or the deadline was reached, deadline already in local
      String nowDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      String localDate = pollData.deadline;
      localDate = DateFormatter.toLocalString(localDate);

      if (!pollData.isClosed && localDate.compareTo(nowDate) <= 0) {
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEvent>(context, listen: false)
            .closePoll(context: context, pollId: widget.pollEventId);
      }

      List<PollEventInviteModel> pollInvites =
          // ignore: use_build_context_synchronously
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromPollEventId(pollEventId: widget.pollEventId);
      if (pollInvites.isEmpty) return null;

      List<VoteLocationModel> votesLocations =
          await Future.wait(pollData.locations.map((location) {
        return Provider.of<FirebaseVote>(context, listen: false)
            .getVotesLocation(
                pollId: widget.pollEventId, locationName: location.name)
            .then((value) {
          if (value != null) {
            value.votes[pollData.organizerUid] = Availability.yes;
            return value;
          } else {
            return VoteLocationModel(
              locationName: location.name,
              pollId: widget.pollEventId,
              votes: {pollData.organizerUid: Availability.yes},
            );
          }
        });
      }).toList());

      List<Future<VoteDateModel>> promises = pollData.dates.keys
          .map((date) {
            return pollData.dates[date].map((slot) {
              return Provider.of<FirebaseVote>(context, listen: false)
                  .getVotesDate(
                pollId: widget.pollEventId,
                date: date,
                start: slot["start"],
                end: slot["end"],
              )
                  .then((value) {
                if (value != null) {
                  value.votes[pollData.organizerUid] = Availability.yes;
                  return value;
                } else {
                  return VoteDateModel(
                    pollId: widget.pollEventId,
                    date: date,
                    start: slot["start"],
                    end: slot["end"],
                    votes: {pollData.organizerUid: Availability.yes},
                  );
                }
              });
            }).toList();
          })
          .toList()
          .expand((x) => x)
          .toList()
          .cast();

      List<VoteDateModel> votesDates = await Future.wait(promises);
      return {
        "data": pollData,
        "invites": pollInvites,
        "locations": votesLocations,
        "dates": votesDates,
      };
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _future = getPollDataAndInvites(context);
  }

  void refreshPollDetail() {
    setState(() {
      _future = null;
      _future = getPollDataAndInvites(context);
      _refresh = !_refresh;
    });
  }

  Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
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

              // check if it is closed or the deadline was reached, deadline already in local
              Map<String, dynamic> tmp =
                  snapshot.data!.data() as Map<String, dynamic>;
              String nowDate =
                  DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
              String localDate = DateFormatter.dateTime2String(
                  (tmp["deadline"] as Timestamp).toDate());
              localDate = DateFormatter.toLocalString(localDate);

              return FutureBuilder<Map<String, dynamic>?>(
                future: _future,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>?> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingLogo();
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

                  // today is below deadline and the poll was not closed early
                  if (localDate.compareTo(nowDate) > 0 && !tmp["isClosed"]) {
                    return PollDetailScreen(
                      pollId: widget.pollEventId,
                      pollData: pollData,
                      pollInvites: pollInvites,
                      votesLocations: votesLocations,
                      votesDates: votesDates,
                      refreshPollDetail: refreshPollDetail,
                    );
                  } else {
                    return const SettingsScreen();
                  }
                },
              );
            });
      },
    );
  }
}
