import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_detail/components/my_poll.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DateDetail extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteModel> invites;
  final VoteDateModel voteDate;
  final ValueChanged<int> modifyVote;
  const DateDetail({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.modifyVote,
    required this.voteDate,
  });

  List<MyPollOption> getOptions(VoteDateModel? voteDateModel) {
    return [
      MyPollOption(
        id: Availability.yes,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.yes]),
            const Text(" Present", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: voteDateModel != null
            ? 1 +
                (voteDateModel
                    .getVotesKind(
                      Availability.yes,
                      invites,
                      organizerUid,
                    )
                    .length)
            : 1,
      ),
      MyPollOption(
        id: Availability.iff,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.iff]),
            const Text(" If need be", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: voteDateModel != null
            ? voteDateModel
                .getVotesKind(
                  Availability.iff,
                  invites,
                  organizerUid,
                )
                .length
            : 0,
      ),
      MyPollOption(
        id: Availability.not,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.not]),
            const Text(" Not present", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: voteDateModel != null
            ? voteDateModel
                .getVotesKind(
                  Availability.not,
                  invites,
                  organizerUid,
                )
                .length
            : 0,
      ),
      MyPollOption(
        id: Availability.empty,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.empty]),
            const Text(" Pending", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: voteDateModel != null
            ? voteDateModel
                .getVotesKind(
                  Availability.empty,
                  invites,
                  organizerUid,
                )
                .length
            : invites.length - 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime =
        DateFormatter.string2DateTime("${voteDate.date} 00:00:00");
    var start = voteDate.start;
    var end = voteDate.end;
    if (!Preferences.getBool('is24Hour')) {
      start = DateFormat("hh:mm a")
          .format(DateFormatter.string2DateTime("2000-01-01 $start:00"));
      end = DateFormat("hh:mm a")
          .format(DateFormatter.string2DateTime("2000-01-01 $end:00"));
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          alignment: Alignment.topLeft,
          child: Text(
            DateFormat("MMMM dd yyyy, EEEE").format(dateTime),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          alignment: Alignment.topLeft,
          child: Text(
            "From $start to $end",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVoteDateSnapshot(
                  pollId: pollId,
                  date: voteDate.date,
                  start: voteDate.start,
                  end: voteDate.end),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingLogo();
            }
            if (snapshot.hasError) {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  ScreenTransition(
                    builder: (context) => ErrorScreen(
                      errorMsg: snapshot.error.toString(),
                    ),
                  ),
                );
              });
              return Container();
            }
            VoteDateModel? voteDateModel;
            var curUid =
                Provider.of<FirebaseUser>(context, listen: false).user!.uid;
            int userVotedOptionId = Availability.empty;
            if (snapshot.data!.exists) {
              voteDateModel = VoteDateModel.fromMap(
                (snapshot.data!.data()) as Map<String, dynamic>,
              );
              userVotedOptionId =
                  voteDateModel.votes[curUid] ?? Availability.empty;
            }
            userVotedOptionId =
                organizerUid == curUid ? Availability.yes : userVotedOptionId;
            return MyPolls(
              curUid: curUid,
              organizerUid: organizerUid,
              votedAnimationDuration: 0,
              votesText: "",
              hasVoted: true,
              userVotedOptionId: userVotedOptionId,
              heightBetweenTitleAndOptions: 0,
              pollId: '1',
              onVoted: (MyPollOption pollOption, int newTotalVotes) async {
                int newAvailability = pollOption.id!;
                await Provider.of<FirebaseVote>(context, listen: false)
                    .userVoteDate(
                        pollId: pollId,
                        date: voteDate.date,
                        start: voteDate.start,
                        end: voteDate.end,
                        uid: curUid,
                        availability: newAvailability);
                modifyVote(newAvailability);
                return true;
              },
              pollOptionsSplashColor: Colors.white,
              votedProgressColor: Colors.grey.withOpacity(0.3),
              votedBackgroundColor: Colors.grey.withOpacity(0.2),
              votedCheckmark: const Icon(
                Icons.check,
              ),
              pollTitle: Container(),
              pollOptions: getOptions(voteDateModel),
              metaWidget: Row(
                children: const [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '2 weeks left',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
      ],
    );
  }
}
