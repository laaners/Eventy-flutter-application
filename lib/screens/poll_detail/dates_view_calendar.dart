import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatesViewCalendar extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteCollection> invites;
  final List<VoteDateCollection> votesDates;
  const DatesViewCalendar({
    super.key,
    required this.organizerUid,
    required this.pollId,
    required this.deadline,
    required this.dates,
    required this.invites,
    required this.votesDates,
  });

  @override
  State<DatesViewCalendar> createState() => _DatesViewCalendarState();
}

class _DatesViewCalendarState extends State<DatesViewCalendar> {
  late List<VoteDateCollection> votesDates;

  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    votesDates = widget.votesDates;
    votesDates.sort((a, b) => a.end.compareTo(b.end));
    votesDates.sort((a, b) => a.start.compareTo(b.start));
    votesDates.sort((a, b) => a.date.compareTo(b.date));
    _focusedDay = DateFormatter.string2DateTime(widget.deadline);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style: const TextStyle(
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
        lastDay:
            DateFormatter.string2DateTime("${votesDates.last.date} 00:00:00"),
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
          String dayString = DateFormatter.dateTime2String(day).split(" ")[0];
          if (widget.dates.containsKey(dayString)) {
            return widget.dates[dayString].toList();
          }
          return [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          print(DateFormatter.dateTime2String(selectedDay));
          print("do something on press");
          _focusedDay = selectedDay;
        },
      ),
    );
  }
}
