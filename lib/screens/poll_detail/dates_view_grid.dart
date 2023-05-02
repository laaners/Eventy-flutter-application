import 'package:dima_app/screens/poll_detail/date_detail.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    DateTime deadlineDate = DateFormatter.string2DateTime(widget.deadline);
    return HorizontalScroller(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.only(
            top: 10,
            right: 10,
            left: 10,
            bottom: 10,
          ),
          width: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColorDark,
          ),
          child: Column(
            children: [
              Text(
                DateFormat("MMM").format(deadlineDate),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              Text(
                DateFormat("dd").format(deadlineDate),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              Text(
                DateFormat("EEEE").format(deadlineDate),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              Text(
                "at ${DateFormat("hh:mm").format(deadlineDate)}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              Text(
                "DEADLINE",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ],
          ),
        ),
        ...widget.votesDates.map((voteDate) {
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
        }).toList()
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
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    int curVote = voteDate.votes[curUid];

    DateTime dateTime =
        DateFormatter.string2DateTime("${voteDate.date} 00:00:00");
    return InkWell(
      onTap: () {
        MyModal.show(
          context: context,
          child: DateDetail(
            pollId: pollId,
            organizerUid: organizerUid,
            invites: invites,
            voteDate: voteDate,
            modifyVote: modifyVote,
          ),
          heightFactor: 0.5,
          doneCancelMode: false,
          onDone: () {},
          title: "",
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).focusColor,
        ),
        child: Column(
          children: [
            Text(
              DateFormat("MMM").format(dateTime),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              DateFormat("dd").format(dateTime),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              DateFormat("EEEE").format(dateTime),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "${voteDate.start}-${voteDate.end}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (voteDate.getPositiveVotes().length).toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(width: 2),
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 22,
                    ),
                  ],
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  child: Ink(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Icon(Availability.icons[curVote]),
                  ),
                  onTap: () async {
                    if (MyAlertDialog.showAlertIfCondition(
                        context,
                        curUid == organizerUid,
                        "YOU CANNOT VOTE",
                        "You are the organizer, you must be present at the event!")) {
                      return;
                    }
                    int newAvailability =
                        curVote + 1 > 2 ? Availability.empty : curVote + 1;

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
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
