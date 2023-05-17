import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'date_tile.dart';

class DatesViewHorizontal extends StatefulWidget {
  final bool isClosed;
  final String organizerUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteModel> invites;
  final List<VoteDateModel> votesDates;
  const DatesViewHorizontal({
    super.key,
    required this.organizerUid,
    required this.pollId,
    required this.deadline,
    required this.dates,
    required this.invites,
    required this.votesDates,
    required this.isClosed,
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
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
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
                "at${Preferences.getBool('is24Hour') ? ' ' : '\n'}${DateFormat(Preferences.getBool('is24Hour') ? "HH:mm" : "hh:mm a").format(deadlineDate)}",
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
