import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatesViewGrid extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteCollection> invites;
  final List<VoteDateCollection> votesDates;
  const DatesViewGrid({
    super.key,
    required this.organizerUid,
    required this.pollId,
    required this.deadline,
    required this.dates,
    required this.invites,
    required this.votesDates,
  });

  @override
  State<DatesViewGrid> createState() => _DatesViewGridState();
}

class _DatesViewGridState extends State<DatesViewGrid> {
  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Column(
      children: widget.votesDates.map((voteDate) {
        return DateTile(
          pollId: widget.pollId,
          organizerUid: widget.organizerUid,
          invites: widget.invites,
          voteDate: voteDate,
          modifyVote: (int newAvailability) {
            setState(() {
              widget
                  .votesDates[widget.votesDates.indexWhere((e) =>
                      e.date == voteDate.date &&
                      e.start == voteDate.start &&
                      e.end == voteDate.end)]
                  .votes[curUid] = newAvailability;
            });
          },
        );
      }).toList(),
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).focusColor,
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
          height: double.infinity,
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
