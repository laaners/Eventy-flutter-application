import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
  bool sortedByVotes = true;
  late List<VoteDateCollection> votesDates;

  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    votesDates = widget.votesDates;
    votesDates.sort((a, b) => a.end.compareTo(b.end));
    votesDates.sort((a, b) => a.start.compareTo(b.start));
    votesDates.sort((a, b) => a.date.compareTo(b.date));
    print(votesDates.map((e) => e.date).toList());
    _focusedDay = DateFormatter.string2DateTime(widget.deadline);
    print(widget.deadline);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return ListView(
      children: [
        MyButton(
          text: "sort test",
          onPressed: () {
            setState(() {
              sortedByVotes = !sortedByVotes;
              if (sortedByVotes) {
                votesDates.sort((a, b) =>
                    b.getPositiveVotes().length - a.getPositiveVotes().length);
              } else {
                votesDates.sort((a, b) => a.votes.length - b.votes.length);
                votesDates.sort((a, b) => a.end.compareTo(b.end));
                votesDates.sort((a, b) => a.start.compareTo(b.start));
                votesDates.sort((a, b) => a.date.compareTo(b.date));
              }
            });
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: TableCalendar(
            headerStyle: const HeaderStyle(
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) {
                DateTime deadlineDate =
                    DateFormatter.string2DateTime(widget.deadline);
                bool isDeadline = deadlineDate.year == day.year &&
                    deadlineDate.month == day.month &&
                    deadlineDate.day == day.day;
                if (isDeadline) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(1),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(1),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      day.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).focusColor,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                return events.isNotEmpty
                    ? Container(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Theme.of(context).focusColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 1.5,
                                horizontal: 5,
                              ),
                              child: Text(
                                events.length.toString(),
                              ),
                            ),
                          ),
                        ),
                      )
                    : null;
              },
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            // firstDay: DateFormatter.string2DateTime(widget.deadline).add(const Duration(days: 1)),
            firstDay: DateTime.now(),
            // lastDay: DateFormatter.string2DateTime(votesDates.last.date),
            // lastDay: DateTime(DateTime.now().year + 50),
            lastDay: DateFormatter.string2DateTime(
                "${votesDates.last.date} 00:00:00"),
            focusedDay: _focusedDay.compareTo(
                        DateFormatter.string2DateTime(widget.deadline)
                            .add(const Duration(days: 1))) <=
                    0
                ? DateFormatter.string2DateTime(widget.deadline)
                    .add(const Duration(days: 1))
                : _focusedDay,
            selectedDayPredicate: (day) {
              return votesDates
                  .map((e) => e.date)
                  .toList()
                  .contains(DateFormatter.dateTime2String(day).split(" ")[0]);
            },
            availableCalendarFormats: const {CalendarFormat.month: 'month'},
            calendarFormat: CalendarFormat.month,
            onDayLongPressed: (selectedDay, focusedDay) {
              print("do something on long press");
            },
            eventLoader: (DateTime day) {
              String dayString = DateFormatter.dateTime2String(day);
              if (widget.dates.containsKey(dayString)) {
                return widget.dates[dayString].entries.toList();
              }
              return [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              print(DateFormatter.dateTime2String(selectedDay));
              print("do something on press");
              _focusedDay = selectedDay;
            },
          ),
        ),
        Column(
          children: votesDates.map((voteDate) {
            return DateTile(
              pollId: widget.pollId,
              organizerUid: widget.organizerUid,
              invites: widget.invites,
              voteDate: voteDate,
              modifyVote: (int newAvailability) {
                setState(() {
                  votesDates[votesDates.indexWhere((e) =>
                          e.date == voteDate.date &&
                          e.start == voteDate.start &&
                          e.end == voteDate.end)]
                      .votes[curUid] = newAvailability;
                });
              },
            );
          }).toList(),
        )
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
          ),
        ),
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
