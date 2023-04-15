import 'package:dima_app/screens/poll_detail/dates_view_calendar.dart';
import 'package:dima_app/screens/poll_detail/dates_view_grid.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class DatesList extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final String deadline;
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
    required this.deadline,
  });

  @override
  State<DatesList> createState() => _DatesListState();
}

class _DatesListState extends State<DatesList>
    with AutomaticKeepAliveClientMixin {
  bool _calendarView = true;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                color: _calendarView ? null : Theme.of(context).focusColor,
                onPressed: () {
                  setState(() {
                    _calendarView = true;
                  });
                },
                icon: const Icon(
                  Icons.calendar_month,
                ),
              ),
              IconButton(
                color: !_calendarView ? null : Theme.of(context).focusColor,
                onPressed: () {
                  setState(() {
                    _calendarView = false;
                  });
                },
                icon: const Icon(
                  Icons.view_list,
                ),
              ),
            ],
          ),
        ),
        _calendarView
            ? DatesViewCalendar(
                organizerUid: widget.organizerUid,
                pollId: widget.pollId,
                deadline: widget.deadline,
                dates: widget.dates,
                invites: widget.invites,
                votesDates: widget.votesDates,
              )
            : DatesViewGrid(
                organizerUid: widget.organizerUid,
                pollId: widget.pollId,
                deadline: widget.deadline,
                dates: widget.dates,
                invites: widget.invites,
                votesDates: widget.votesDates,
              ),
      ],
    );
  }
}
