import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/screens/poll_detail/components/dates_view_horizontal.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'availability_legend.dart';
import 'dates_view_calendar.dart';

class DatesList extends StatefulWidget {
  final bool isClosed;
  final String organizerUid;
  final String votingUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteModel> invites;
  final List<VoteDateModel> votesDates;
  const DatesList({
    super.key,
    required this.dates,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.votesDates,
    required this.deadline,
    required this.isClosed,
    required this.votingUid,
  });

  @override
  State<DatesList> createState() => _DatesListState();
}

class _DatesListState extends State<DatesList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<VoteDateModel> votesDates;
  bool chronoAsc = true;
  bool votesDesc = true;

  int filterAvailability = -2;
  bool Function(VoteDateModel voteDate) filter =
      (VoteDateModel voteDate) => true;

  @override
  void initState() {
    super.initState();
    votesDates = List.from(widget.votesDates);
    votesDates.sort(
        (a, b) => b.getPositiveVotes().length - a.getPositiveVotes().length);
    votesDates.sort((a, b) => "${a.date} ${a.start}-${a.end}"
        .compareTo("${b.date} ${b.start}-${b.end}"));
  }

  updateFilterAfterVote() {
    if (filterAvailability == -2) return;
    setState(() {
      filterAvailability = -2;
      votesDates = List.from(widget.votesDates);
      chronoAsc
          ? votesDates.sort((a, b) => "${a.date} ${a.start}-${a.end}"
              .compareTo("${b.date} ${b.start}-${b.end}"))
          : votesDates.sort((a, b) => "${b.date} ${b.start}-${b.end}"
              .compareTo("${a.date} ${a.start}-${a.end}"));
      votesDesc
          ? votesDates.sort((a, b) =>
              b.getPositiveVotes().length - a.getPositiveVotes().length)
          : votesDates.sort((a, b) =>
              a.getPositiveVotes().length - b.getPositiveVotes().length);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final curUid = Provider.of<FirebaseUser>(listen: false, context).user!.uid;
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvailabilityLegend(
                filterAvailability: filterAvailability,
                changeFilterAvailability: (int value) {
                  setState(() {
                    filterAvailability = value;
                    if (value == -2) {
                      votesDates = List.from(widget.votesDates);
                    } else if (value == Availability.empty) {
                      votesDates = List.from(widget.votesDates);
                      votesDates = votesDates
                          .where((voteLocation) =>
                              voteLocation.votes[widget.votingUid] == null ||
                              voteLocation.votes[widget.votingUid] == value)
                          .toList();
                    } else {
                      votesDates = List.from(widget.votesDates);
                      votesDates = votesDates
                          .where((voteLocation) =>
                              voteLocation.votes[widget.votingUid] == value)
                          .toList();
                    }
                    chronoAsc
                        ? votesDates.sort((a, b) =>
                            "${a.date} ${a.start}-${a.end}"
                                .compareTo("${b.date} ${b.start}-${b.end}"))
                        : votesDates.sort((a, b) =>
                            "${b.date} ${b.start}-${b.end}"
                                .compareTo("${a.date} ${a.start}-${a.end}"));
                    votesDesc
                        ? votesDates.sort((a, b) =>
                            b.getPositiveVotes().length -
                            a.getPositiveVotes().length)
                        : votesDates.sort((a, b) =>
                            a.getPositiveVotes().length -
                            b.getPositiveVotes().length);
                  });
                },
              ),
              Row(
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
                                "${b.date} ${b.start}-${b.end}".compareTo(
                                    "${a.date} ${a.start}-${a.end}"));
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
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          // calendar overflow problem: column when in modal (viewing other people votes), listview when not modal (viewing current user votes)
          child: curUid == widget.votingUid
              ? ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    DatesViewHorizontal(
                      isClosed: widget.isClosed,
                      organizerUid: widget.organizerUid,
                      votingUid: widget.votingUid,
                      pollId: widget.pollId,
                      deadline: widget.deadline,
                      dates: widget.dates,
                      invites: widget.invites,
                      votesDates: votesDates.where(filter).toList(),
                      updateFilterAfterVote: updateFilterAfterVote,
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
                            filter = (VoteDateModel voteDate) {
                              return true;
                            };
                          } else {
                            filter = (VoteDateModel voteDate) {
                              return voteDate.date == selectedDateString;
                            };
                          }
                        });
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    DatesViewHorizontal(
                      isClosed: widget.isClosed,
                      organizerUid: widget.organizerUid,
                      votingUid: widget.votingUid,
                      pollId: widget.pollId,
                      deadline: widget.deadline,
                      dates: widget.dates,
                      invites: widget.invites,
                      votesDates: votesDates.where(filter).toList(),
                      updateFilterAfterVote: updateFilterAfterVote,
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
                            filter = (VoteDateModel voteDate) {
                              return true;
                            };
                          } else {
                            filter = (VoteDateModel voteDate) {
                              return voteDate.date == selectedDateString;
                            };
                          }
                        });
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
