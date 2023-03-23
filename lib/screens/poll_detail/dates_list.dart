import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class DatesList extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final Map<String, dynamic> dates;
  final List<PollEventInviteCollection> invites;
  const DatesList({
    super.key,
    required this.dates,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
  });

  @override
  State<DatesList> createState() => _DatesListState();
}

class _DatesListState extends State<DatesList> {
  bool sortedByVotes = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyButton(
          text: "sort test",
          onPressed: () {
            setState(() {
              sortedByVotes = !sortedByVotes;
            });
          },
        ),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVotesDatesSnapshots(widget.pollId),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingSpinner();
            }
            if (snapshot.hasError || snapshot.data == null) {
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
            List<VoteDateCollection> datesVotesCollection = [];
            if (snapshot.data!.docs.isNotEmpty) {
              datesVotesCollection =
                  snapshot.data!.docs.map<VoteDateCollection>((e) {
                return VoteDateCollection.fromMap(
                  e.data() as Map<String, dynamic>,
                );
              }).toList();
            }
            widget.dates.forEach((key, dates) {
              for (var date in dates) {
                VoteDateCollection? voteDateCollection =
                    datesVotesCollection.firstWhereOrNull(
                  (element) =>
                      element.date == key &&
                      element.start == date["start"] &&
                      element.end == date["end"],
                );
                if (voteDateCollection == null) {
                  datesVotesCollection.add(
                    VoteDateCollection(
                      pollId: widget.pollId,
                      date: key,
                      start: date["start"],
                      end: date["end"],
                      votes: {
                        widget.organizerUid: Availability.yes,
                      },
                    ),
                  );
                } else {
                  voteDateCollection.votes[widget.organizerUid] =
                      Availability.yes;
                }
              }
            });
            // UTC to local
            List<VoteDateCollection> localDates = [];
            for (var dateVoteCollection in datesVotesCollection) {
              var startDateString =
                  "${dateVoteCollection.date} ${dateVoteCollection.start}:00";
              var endDateString =
                  "${dateVoteCollection.date} ${dateVoteCollection.end}:00";
              var startDateLocal = DateFormatter.string2DateTime(
                  DateFormatter.toLocalString(startDateString));
              var endDateLocal = DateFormatter.string2DateTime(
                  DateFormatter.toLocalString(endDateString));
              String localDay = DateFormat("yyyy-MM-dd").format(startDateLocal);
              var startLocal = DateFormat("HH:mm").format(startDateLocal);
              var endLocal = DateFormat("HH:mm").format(endDateLocal);
              localDates.add(VoteDateCollection(
                pollId: widget.pollId,
                date: localDay,
                start: startLocal,
                end: endLocal,
                votes: dateVoteCollection.votes,
              ));
            }
            datesVotesCollection = localDates;
            if (sortedByVotes) {
              datesVotesCollection.sort((a, b) =>
                  b.getPositiveVotes().length - a.getPositiveVotes().length);
            } else {
              datesVotesCollection
                  .sort((a, b) => a.votes.length - b.votes.length);
              datesVotesCollection.sort((a, b) => a.end.compareTo(b.end));
              datesVotesCollection.sort((a, b) => a.start.compareTo(b.start));
              datesVotesCollection.sort((a, b) => a.date.compareTo(b.date));
            }
            return Column(
              children: datesVotesCollection.map((voteDateCollection) {
                return DateTile(
                  pollId: widget.pollId,
                  organizerUid: widget.organizerUid,
                  invites: widget.invites,
                  voteDateCollection: voteDateCollection,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class DateTile extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
  final VoteDateCollection voteDateCollection;
  const DateTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.voteDateCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Palette.greyColor,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          voteDateCollection.date,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          voteDateCollection.start + "_" + voteDateCollection.end,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Palette.lightBGColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Palette.greyColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((voteDateCollection.getPositiveVotes().length).toString()),
            IconButton(
              icon: const Icon(
                Icons.check,
                color: Colors.green,
              ),
              onPressed: () {},
            ),
          ],
        ),
        onTap: () {
          /*
          Navigator.push(
            context,
            ScreenTransition(
              builder: (context) => Scaffold(
                appBar: MyAppBar(location.name),
                body: Container(
                  // margin: const EdgeInsets.only(top: 15, bottom: 15),
                  child: LocationDetail(
                    pollId: pollId,
                    organizerUid: organizerUid,
                    invites: invites,
                    location: location,
                  ),
                ),
              ),
            ),
          );
          */
        },
      ),
    );
  }
}
