import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/poll_detail/dates_list.dart';
import 'package:dima_app/screens/poll_detail/invitees_pill.dart';
import 'package:dima_app/screens/poll_detail/locations_list.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/lists_switcher.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PollDetailScreen extends StatelessWidget {
  final String pollId;

  const PollDetailScreen({
    super.key,
    required this.pollId,
  });

  Future<Map<String, dynamic>?> getPollDataAndInvites(
      BuildContext context) async {
    PollCollection? pollData =
        await Provider.of<FirebasePoll>(context, listen: false)
            .getPollData(context, pollId);
    if (pollData == null) return null;
    List<PollEventInviteCollection> pollInvites =
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEventInvite>(context, listen: false)
            .getInvitesFromPollEventId(context, pollId);
    if (pollInvites.isEmpty) return null;

    List<VoteLocationCollection> votesLocations =
        await Future.wait(pollData.locations.map((location) {
      return Provider.of<FirebaseVote>(context, listen: false)
          .getVotesLocation(context, pollId, location["name"])
          .then((value) {
        if (value != null) {
          value.votes[pollData.organizerUid] = Availability.yes;
          return value;
        } else {
          return VoteLocationCollection(
            locationName: location["name"],
            pollId: pollId,
            votes: {
              pollData.organizerUid: Availability.yes,
            },
          );
        }
      });
    }).toList());

    List<Future<VoteDateCollection>> promises = pollData.dates.keys
        .map((date) {
          return pollData.dates[date].map((slot) {
            return Provider.of<FirebaseVote>(context, listen: false)
                .getVotesDate(context, pollId, date, slot["start"], slot["end"])
                .then((value) {
              if (value != null) {
                value.votes[pollData.organizerUid] = Availability.yes;
                return value;
              } else {
                return VoteDateCollection(
                  pollId: pollId,
                  date: date,
                  start: slot["start"],
                  end: slot["end"],
                  votes: {
                    pollData.organizerUid: Availability.yes,
                  },
                );
              }
            });
          }).toList();
        })
        .toList()
        .expand((x) => x)
        .toList()
        .cast();

    List<VoteDateCollection> votesDates = await Future.wait(promises);
    print(votesDates[5]);
    List<VoteDateCollection> localDates = [];
    for (var voteDate in votesDates) {
      var startDateString = "${voteDate.date} ${voteDate.start}:00";
      var endDateString = "${voteDate.date} ${voteDate.end}:00";
      var startDateLocal = DateFormatter.string2DateTime(
          DateFormatter.toLocalString(startDateString));
      var endDateLocal = DateFormatter.string2DateTime(
          DateFormatter.toLocalString(endDateString));
      String localDay = DateFormat("yyyy-MM-dd").format(startDateLocal);
      var startLocal = DateFormat("HH:mm").format(startDateLocal);
      var endLocal = DateFormat("HH:mm").format(endDateLocal);
      localDates.add(VoteDateCollection(
        pollId: pollId,
        date: localDay,
        start: startLocal,
        end: endLocal,
        votes: voteDate.votes,
      ));
    }
    votesDates = localDates;

    return {
      "data": pollData,
      "invites": pollInvites,
      "locations": votesLocations,
      "dates": votesDates,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Poll Detail"),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getPollDataAndInvites(context),
        builder: (
          BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSpinner();
          }
          if (snapshot.hasError || !snapshot.hasData) {
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
          PollCollection pollData = snapshot.data!["data"];
          List<PollEventInviteCollection> pollInvites =
              snapshot.data!["invites"];
          List<VoteLocationCollection> votesLocations =
              snapshot.data!["locations"];
          votesLocations.sort((a, b) =>
              b.getPositiveVotes().length - a.getPositiveVotes().length);
          List<VoteDateCollection> votesDates = snapshot.data!["dates"];
          votesDates.sort((a, b) =>
              b.getPositiveVotes().length - a.getPositiveVotes().length);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      pollData.pollName,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const Text(
                  "Organized by",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                UserTile(userUid: pollData.organizerUid),
                const Text(
                  "About this event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                Text(pollData.pollDesc.isEmpty
                    ? "The organized did not provide any description"
                    : pollData.pollDesc),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                InviteesPill(
                  pollEventId: pollId,
                  invites: pollInvites,
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                const Text(
                  "Where this event could be held",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                ListsSwitcher(
                  labels: const ["Locations", "Dates"],
                  lists: [
                    LocationsList(
                      organizerUid: pollData.organizerUid,
                      pollId: pollId,
                      locations: pollData.locations,
                      invites: pollInvites,
                      votesLocations: votesLocations,
                    ),
                    DatesList(
                      organizerUid: pollData.organizerUid,
                      pollId: pollId,
                      dates: pollData.dates,
                      invites: pollInvites,
                      votesDates: votesDates,
                    ),
                  ],
                ),
                const Text(
                  "When this event could be held",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(pollData.deadline),
                Text(pollData.public.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
