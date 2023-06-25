import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'date_detail.dart';

class DateTile extends StatelessWidget {
  final bool isClosed;
  final String pollId;
  final String organizerUid;
  final String votingUid;
  final List<PollEventInviteModel> invites;
  final VoteDateModel voteDate;
  final ValueChanged<int> modifyVote;
  const DateTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.voteDate,
    required this.modifyVote,
    required this.isClosed,
    required this.votingUid,
  });

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    int curVote = voteDate.votes[votingUid] ?? Availability.empty;

    DateTime dateTime =
        DateFormatter.string2DateTime("${voteDate.date} 00:00:00");

    var start = voteDate.start;
    var end = voteDate.end;
    if (!Provider.of<ClockManager>(context).clockMode) {
      start = DateFormat("hh:mm a")
          .format(DateFormatter.string2DateTime("2000-01-01 $start:00"));
      end = DateFormat("hh:mm a")
          .format(DateFormatter.string2DateTime("2000-01-01 $end:00"));
    }
    return InkWell(
      onTap: () {
        MyModal.show(
          context: context,
          shrinkWrap: false,
          child: DateDetail(
            isClosed: isClosed,
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
      child: ContainerShadow(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        width: 110,
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
              "$start${Provider.of<ClockManager>(context).clockMode ? '-' : ' '}$end",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
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
                MyIconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Availability.icons[curVote]),
                  onTap: () async {
                    if (isClosed) return;
                    if (votingUid == curUid) {
                      if (MyAlertDialog.showAlertIfCondition(
                        context: context,
                        condition: votingUid == organizerUid,
                        title: "You cannot vote",
                        content:
                            "You are the organizer, you must be present at the event!",
                      )) {
                        return;
                      }
                      int newAvailability =
                          curVote + 1 > 2 ? Availability.empty : curVote + 1;

                      await Provider.of<FirebaseVote>(context, listen: false)
                          .userVoteDate(
                              pollId: pollId,
                              date: voteDate.date,
                              start: voteDate.start,
                              end: voteDate.end,
                              uid: votingUid,
                              availability: newAvailability);
                      modifyVote(newAvailability);
                    }
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
