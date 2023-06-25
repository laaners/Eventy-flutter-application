import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'date_tile.dart';

class DatesViewHorizontal extends StatefulWidget {
  final bool isClosed;
  final String organizerUid;
  final String votingUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteModel> invites;
  final List<VoteDateModel> votesDates;
  final VoidCallback updateFilterAfterVote;
  const DatesViewHorizontal({
    super.key,
    required this.organizerUid,
    required this.pollId,
    required this.deadline,
    required this.dates,
    required this.invites,
    required this.votesDates,
    required this.isClosed,
    required this.updateFilterAfterVote,
    required this.votingUid,
  });

  @override
  State<DatesViewHorizontal> createState() => _DatesViewHorizontalState();
}

class _DatesViewHorizontalState extends State<DatesViewHorizontal> {
  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    DateTime deadlineDate = DateFormatter.string2DateTime(widget.deadline);
    return HorizontalScroller(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerShadow(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(10),
          width: 110,
          color: Theme.of(context).primaryColorDark,
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
                "at${Provider.of<ClockManager>(context).clockMode ? ' ' : '\n'}${DateFormat(Provider.of<ClockManager>(context).clockMode ? "HH:mm" : "hh:mm a").format(deadlineDate)}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
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
            isClosed: widget.isClosed,
            pollId: widget.pollId,
            organizerUid: widget.organizerUid,
            votingUid: widget.votingUid,
            invites: widget.invites,
            voteDate: voteDate,
            modifyVote: (int newAvailability) {
              if (widget.isClosed) return;
              if (widget.votingUid == curUid) {
                setState(() {
                  widget
                      .votesDates[widget.votesDates.indexWhere((e) =>
                          e.date == voteDate.date &&
                          e.start == voteDate.start &&
                          e.end == voteDate.end)]
                      .votes[curUid] = newAvailability;
                });
                widget.updateFilterAfterVote();
              }
            },
          );
        }).toList()
      ],
    );
  }
}
