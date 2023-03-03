import 'package:dima_app/screens/event_create/select_day_slots.dart';
import 'package:dima_app/screens/event_create/select_slot.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class StepDates extends StatefulWidget {
  final Map<String, dynamic> dates;
  final ValueChanged<List<String>> addDate;
  final ValueChanged<List<String>> removeDate;
  final TextEditingController deadlineController;
  const StepDates({
    super.key,
    required this.dates,
    required this.addDate,
    required this.removeDate,
    required this.deadlineController,
  });

  @override
  State<StepDates> createState() => _StepDatesState();
}

class _StepDatesState extends State<StepDates> {
  DateTime _focusedDay = DateTime.now();
  bool _fixedTimeSlots = false;
  List<Map<String, String>> _timeSlots = [];

  void setSlot(times) {
    setState(() {
      var start = times[0].toString();
      var end = times[1].toString();
      var dayString = times[2];
      if (dayString == "all") {
        var slot = {"start": start, "end": end};
        bool exists = _timeSlots
            .map((obj) => obj["start"]! + obj["end"]!)
            .contains(start + end);
        if (!exists) {
          _timeSlots.add(slot);
          _timeSlots.sort((a, b) => a["end"]!.compareTo(b["end"]!));
          _timeSlots.sort((a, b) => a["start"]!.compareTo(b["start"]!));
        }
        widget.dates.forEach((k, v) {
          widget.addDate([k, "$start-$end"]);
        });
      } else {
        widget.addDate([dayString, "$start-$end"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0, top: 8, left: 16),
          alignment: Alignment.topLeft,
          child: const Text(
            "Select the dates, time and duration",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        PillBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Same time(s) for all dates",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 50 * 1.4,
                height: 40 * 1.4,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: _fixedTimeSlots,
                    onChanged: (value) async {
                      if (value) {
                        setState(() {
                          _fixedTimeSlots = false;
                        });
                        await showModalBottomSheet(
                          useRootNavigator: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.4,
                            child: SelectSlot(
                              dayString: "all",
                              setSlot: setSlot,
                            ),
                          ),
                        );
                      } else {
                        for (var slot in _timeSlots) {
                          var start = slot["start"];
                          var end = slot["end"];
                          widget.dates.forEach((k, v) {
                            widget.removeDate([k, "$start-$end"]);
                          });
                        }
                        setState(() {
                          _timeSlots = [];
                        });
                      }
                      setState(() {
                        _fixedTimeSlots = _timeSlots.isNotEmpty ? true : false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_fixedTimeSlots)
          Container(
            margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
            alignment: Alignment.topLeft,
            child: const Text.rich(
              TextSpan(
                text: 'Enable this option to include the same ',
                style: TextStyle(fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: 'additional',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' time slots for ',
                  ),
                  TextSpan(
                    text: 'all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " the selected days",
                  ),
                ],
              ),
            ),
          ),
        if (_fixedTimeSlots)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: ListTile(
              title: const Text(
                "Add another time slot",
                style: TextStyle(
                  color: Palette.blueColor,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Palette.lightBGColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Palette.blueColor,
                ),
              ),
              onTap: () async {
                await showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.4,
                    child: SelectSlot(
                      dayString: "all",
                      setSlot: setSlot,
                    ),
                  ),
                );
              },
            ),
          ),
        HorizontalScroller(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _timeSlots.map((slot) {
            var start = slot["start"];
            var end = slot["end"];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Palette.blueColor,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "$start-$end",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 5,
                    ),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      widget.dates.forEach((k, v) {
                        widget.removeDate([k, "$start-$end"]);
                      });
                      setState(() {
                        _timeSlots.removeWhere((item) =>
                            item["start"] == start && item["end"] == end);
                        _fixedTimeSlots = _timeSlots.isEmpty ? false : true;
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
          alignment: Alignment.topLeft,
          child: const Text.rich(
            TextSpan(
              text: '',
              style: TextStyle(fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                  text: 'Long tap',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' on a selected day to edit its time slots',
                ),
              ],
            ),
          ),
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
                        color: Palette.greyColor,
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
                        color: Palette.greyColor,
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
                    color: Palette.blueColor,
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
                                color: Palette.greyColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 1.5,
                                horizontal: 5,
                              ),
                              child: Text(
                                events.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
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
            firstDay: DateTime.now(),
            lastDay:
                DateFormatter.string2DateTime(widget.deadlineController.text),
            focusedDay: _focusedDay.compareTo(DateFormatter.string2DateTime(
                        widget.deadlineController.text)) <=
                    0
                ? _focusedDay
                : DateFormatter.string2DateTime(widget.deadlineController.text),
            selectedDayPredicate: (day) {
              return widget.dates[DateFormatter.dateTime2String(day)] != null;
            },
            availableCalendarFormats: const {CalendarFormat.month: 'month'},
            calendarFormat: CalendarFormat.month,
            onDayLongPressed: (selectedDay, focusedDay) {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    child: SelectDaySlots(
                      day: selectedDay,
                      dates: widget.dates,
                      addDate: widget.addDate,
                      removeDate: widget.removeDate,
                      setSlot: setSlot,
                    ),
                  ),
                ),
              );
            },
            eventLoader: (DateTime day) {
              String dayString = DateFormatter.dateTime2String(day);
              if (widget.dates.containsKey(dayString)) {
                return widget.dates[dayString].entries.toList();
              }
              return [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              String selectedDayString =
                  DateFormatter.dateTime2String(selectedDay);
              if (widget.dates.containsKey(selectedDayString)) {
                widget.removeDate([selectedDayString, "all"]);
              } else {
                for (var slot in _timeSlots) {
                  var start = slot["start"];
                  var end = slot["end"];
                  widget.addDate([selectedDayString, "$start-$end"]);
                }
              }
              _focusedDay = selectedDay;
            },
          ),
        ),
      ],
    );
  }
}