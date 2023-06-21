import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/date_detail.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MostVotedDateTile extends StatelessWidget {
  final PollEventModel pollData;
  final String pollId;
  final List<PollEventInviteModel> invites;
  final List<VoteDateModel> votesDates;
  const MostVotedDateTile({
    super.key,
    required this.votesDates,
    required this.pollData,
    required this.pollId,
    required this.invites,
  });

  @override
  Widget build(BuildContext context) {
    votesDates.sort(
        (a, b) => b.getPositiveVotes().length - a.getPositiveVotes().length);
    VoteDateModel voteDate = votesDates.first;

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

    return MyListTile(
      horizontalTitleGap: 25,
      leading: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FittedBox(child: Icon(Icons.calendar_month, size: 35)),
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
      title: DateFormat("MMMM dd yyyy, EEEE").format(dateTime),
      subtitle: "From $start to $end",
      onTap: () {
        MyModal.show(
          context: context,
          child: DateDetail(
            pollId: pollId,
            organizerUid: pollData.organizerUid,
            invites: invites,
            modifyVote: (value) {},
            voteDate: voteDate,
            isClosed: true,
          ),
          heightFactor: 0.5,
          doneCancelMode: false,
          onDone: () {},
          title: "",
        );
      },
    );
  }
}
