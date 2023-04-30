import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/poll_detail/my_poll.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateDetail extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
  final VoteDateCollection voteDate;
  final ValueChanged<int> modifyVote;
  const DateDetail({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.modifyVote,
    required this.voteDate,
  });

  List<MyPollOption> getOptions(VoteDateCollection? voteDateCollection) {
    return [
      MyPollOption(
        id: Availability.yes,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.yes]),
            const Text(" Present", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: voteDateCollection != null
            ? 1 +
                (voteDateCollection
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
        votes: voteDateCollection != null
            ? voteDateCollection
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
        votes: voteDateCollection != null
            ? voteDateCollection
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
        votes: voteDateCollection != null
            ? voteDateCollection
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
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            voteDate.date,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            "Votes",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVoteDateSnapshot(
                  context, pollId, voteDate.date, voteDate.start, voteDate.end),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingSpinner();
            }
            if (snapshot.hasError) {
              Future.microtask(() {
                Navigator.of(context).pop();
                Navigator.push(
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
            VoteDateCollection? voteDateCollection;
            var curUid =
                Provider.of<FirebaseUser>(context, listen: false).user!.uid;
            int userVotedOptionId = Availability.empty;
            if (snapshot.data!.exists) {
              voteDateCollection = VoteDateCollection.fromMap(
                (snapshot.data!.data()) as Map<String, dynamic>,
              );
              userVotedOptionId =
                  voteDateCollection.votes[curUid] ?? Availability.empty;
            }
            userVotedOptionId =
                organizerUid == curUid ? Availability.yes : userVotedOptionId;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: MyPolls(
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
                    context,
                    pollId,
                    voteDate.date,
                    voteDate.start,
                    voteDate.end,
                    curUid,
                    newAvailability,
                  );
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
                pollOptions: getOptions(voteDateCollection),
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
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
      ],
    );
  }
}
