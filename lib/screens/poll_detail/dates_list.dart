import 'package:dima_app/screens/poll_detail/dates_view_calendar.dart';
import 'package:dima_app/screens/poll_detail/dates_view_grid.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:flutter/material.dart';
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
  @override
  bool get wantKeepAlive => true;

  late List<VoteDateCollection> votesDates;
  bool chronoAsc = true;
  bool votesDesc = true;

  bool Function(VoteDateCollection voteDate) filter =
      (VoteDateCollection voteDate) => true;

  @override
  void initState() {
    super.initState();
    votesDates = List.from(widget.votesDates);
    votesDates.sort(
        (a, b) => b.getPositiveVotes().length - a.getPositiveVotes().length);
    votesDates.sort((a, b) => "${a.date} ${a.start}-${a.end}"
        .compareTo("${b.date} ${b.start}-${b.end}"));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    chronoAsc = !chronoAsc;
                    chronoAsc
                        ? votesDates.sort((a, b) =>
                            "${a.date} ${a.start}-${a.end}"
                                .compareTo("${b.date} ${b.start}-${b.end}"))
                        : votesDates.sort((a, b) =>
                            "${b.date} ${b.start}-${b.end}"
                                .compareTo("${a.date} ${a.start}-${a.end}"));
                  });
                },
                icon: const Icon(
                  Icons.access_time_outlined,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    votesDesc = !votesDesc;
                    votesDesc
                        ? votesDates.sort((a, b) =>
                            b.getPositiveVotes().length -
                            a.getPositiveVotes().length)
                        : votesDates.sort((a, b) =>
                            a.getPositiveVotes().length -
                            b.getPositiveVotes().length);
                  });
                },
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(votesDesc ? 0 : math.pi),
                  child: const Icon(
                    Icons.sort,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DatesViewGrid(
                      organizerUid: widget.organizerUid,
                      pollId: widget.pollId,
                      deadline: widget.deadline,
                      dates: widget.dates,
                      invites: widget.invites,
                      votesDates: votesDates.where(filter).toList(),
                    ),
                    DatesViewCalendar(
                        organizerUid: widget.organizerUid,
                        pollId: widget.pollId,
                        deadline: widget.deadline,
                        dates: widget.dates,
                        invites: widget.invites,
                        votesDates: widget.votesDates,
                        filterDates: (selectedDateString) {
                          setState(() {
                            if (selectedDateString == "all") {
                              filter = (VoteDateCollection voteDate) {
                                return true;
                              };
                            } else {
                              filter = (VoteDateCollection voteDate) {
                                return voteDate.date == selectedDateString;
                              };
                            }
                          });
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
