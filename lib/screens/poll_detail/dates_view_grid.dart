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
    return HorizontalScroller(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
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
          heightFactor: 0.85,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // color: Theme.of(context).focusColor,
      ),
      child: ListTile(
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        title: Text(
          voteDate.date,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${voteDate.start}_${voteDate.end}",
          overflow: TextOverflow.ellipsis,
        ),
        leading: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_outlined),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text((voteDate.getPositiveVotes().length).toString()),
                  Container(width: 2),
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: SizedBox(
          height: double.infinity,
          child: InkWell(
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

              var startDateString = "${voteDate.date} ${voteDate.start}:00";
              var endDateString = "${voteDate.date} ${voteDate.end}:00";
              var startDateUtc = DateFormatter.string2DateTime(
                  DateFormatter.toUtcString(startDateString));
              var endDateUtc = DateFormatter.string2DateTime(
                  DateFormatter.toUtcString(endDateString));
              String utcDay = DateFormat("yyyy-MM-dd").format(startDateUtc);
              var startUtc = DateFormat("HH:mm").format(startDateUtc);
              var endUtc = DateFormat("HH:mm").format(endDateUtc);
              await Provider.of<FirebaseVote>(context, listen: false)
                  .userVoteDate(
                context,
                pollId,
                utcDay,
                startUtc,
                endUtc,
                curUid,
                newAvailability,
              );
              modifyVote(newAvailability);
            },
          ),
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
