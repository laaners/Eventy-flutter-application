import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DatesViewCalendar extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final String deadline;
  final Map<String, dynamic> dates;
  final List<PollEventInviteModel> invites;
  final List<VoteDateModel> votesDates;
  final ValueChanged<String> filterDates;
  const DatesViewCalendar({
    super.key,
    required this.organizerUid,
    required this.pollId,
    required this.deadline,
    required this.dates,
    required this.invites,
    required this.votesDates,
    required this.filterDates,
  });

  @override
  State<DatesViewCalendar> createState() => _DatesViewCalendarState();
}

class _DatesViewCalendarState extends State<DatesViewCalendar> {
  late DateTime _focusedDay;
  DateTime? _filterDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateFormatter.string2DateTime(widget.deadline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContainerShadow(
          margin: const EdgeInsets.only(
            top: 10,
            right: 5,
            left: 5,
            bottom: LayoutConstants.kPaddingFromCreate,
          ),
          padding: const EdgeInsets.all(5),
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
                    color: day == _filterDay
                        ? Theme.of(context).primaryColorLight
                        : Theme.of(context).focusColor,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: day == _filterDay
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
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
                                color: day == _filterDay
                                    ? Theme.of(context).primaryColorLight
                                    : Theme.of(context).focusColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 1.5,
                                horizontal: 5,
                              ),
                              child: Text(
                                events.length.toString(),
                                style: TextStyle(
                                  color: day == _filterDay
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
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
            firstDay: DateFormatter.string2DateTime(widget.deadline)
                    .isBefore(DateTime.now())
                ? DateFormatter.string2DateTime(widget.deadline)
                : DateTime.now(),
            // lastDay: DateFormatter.string2DateTime(votesDates.last.date),
            // lastDay: DateTime(DateTime.now().year + 50),
            lastDay: DateFormatter.string2DateTime(
                "${widget.votesDates.reduce((curr, next) => curr.date.compareTo(next.date) > 0 ? curr : next).date} 00:00:00"),
            focusedDay: _focusedDay.compareTo(
                        DateFormatter.string2DateTime(widget.deadline)
                            .add(const Duration(days: 1))) <=
                    0
                ? DateFormatter.string2DateTime(widget.deadline)
                    .add(const Duration(days: 1))
                : _focusedDay,
            selectedDayPredicate: (day) {
              return widget.votesDates
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
              String dayString =
                  DateFormatter.dateTime2String(day).split(" ")[0];
              if (widget.dates.containsKey(dayString)) {
                return widget.dates[dayString].toList();
              }
              return [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              // print(DateFormatter.dateTime2String(selectedDay));
              _focusedDay = selectedDay;
              if (widget.votesDates.map((e) => e.date).toList().contains(
                  DateFormatter.dateTime2String(selectedDay).split(" ")[0])) {
                if (selectedDay == _filterDay) {
                  widget.filterDates("all");
                  _filterDay = null;
                } else {
                  _filterDay = selectedDay;
                  widget.filterDates(
                      DateFormat("yyyy-MM-dd").format(selectedDay));
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
