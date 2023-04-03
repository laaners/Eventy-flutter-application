import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatesList extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final Map<String, dynamic> dates;
  final List<PollEventInviteCollection> invites;
  final List<VoteDateCollection> votesDates;

  const DatesList({
    super.key,
    required this.dates,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.votesDates,
  });

  @override
  State<DatesList> createState() => _DatesListState();
}

class _DatesListState extends State<DatesList>
    with AutomaticKeepAliveClientMixin {
  bool sortedByVotes = true;
  late List<VoteDateCollection> votesDates;

  @override
  void initState() {
    super.initState();
    votesDates = widget.votesDates;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return ListView(
      children: [
        MyButton(
          text: "sort test",
          onPressed: () {
            setState(() {
              sortedByVotes = !sortedByVotes;
              if (sortedByVotes) {
                votesDates.sort((a, b) =>
                    b.getPositiveVotes().length - a.getPositiveVotes().length);
              } else {
                votesDates.sort((a, b) => a.votes.length - b.votes.length);
                votesDates.sort((a, b) => a.end.compareTo(b.end));
                votesDates.sort((a, b) => a.start.compareTo(b.start));
                votesDates.sort((a, b) => a.date.compareTo(b.date));
              }
            });
          },
        ),
        Column(
          children: votesDates.map((voteDate) {
            return DateTile(
              pollId: widget.pollId,
              organizerUid: widget.organizerUid,
              invites: widget.invites,
              voteDate: voteDate,
              modifyVote: (int newAvailability) {
                setState(() {
                  votesDates[votesDates.indexWhere((e) =>
                          e.date == voteDate.date &&
                          e.start == voteDate.start &&
                          e.end == voteDate.end)]
                      .votes[curUid] = newAvailability;
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }
}

class DateTile extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
  final VoteDateCollection voteDate;
  final ValueChanged<int> modifyVote;
  const DateTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.voteDate,
    required this.modifyVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          voteDate.date,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          voteDate.start + "_" + voteDate.end,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.location_on_outlined,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((voteDate.getPositiveVotes().length).toString()),
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
          modifyVote(Availability.not);
        },
      ),
    );
  }
}
