import 'package:dima_app/providers/preferences.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StepBasics extends StatefulWidget {
  final TextEditingController eventTitleController;
  final TextEditingController eventDescController;
  final TextEditingController deadlineController;
  final Map<String, dynamic> dates;
  final ValueChanged<List<String>> removeDays;
  final ValueChanged<DateTime> setDeadline;
  final bool visibility;
  final VoidCallback changeVisibility;
  final bool canInvite;
  final VoidCallback changeCanInvite;

  const StepBasics({
    super.key,
    required this.eventTitleController,
    required this.eventDescController,
    required this.deadlineController,
    required this.setDeadline,
    required this.dates,
    required this.removeDays,
    required this.visibility,
    required this.changeVisibility,
    required this.canInvite,
    required this.changeCanInvite,
  });

  @override
  State<StepBasics> createState() => _StepBasicsState();
}

class _StepBasicsState extends State<StepBasics> {
  late DateTime _pickedDate;

  @override
  void initState() {
    super.initState();
    _pickedDate = DateFormatter.string2DateTime(widget.deadlineController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            "Title",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: MyTextField(
            maxLength: 40,
            maxLines: 2,
            hintText: "What's the occasion?",
            controller: widget.eventTitleController,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            "Description (optional)",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: MyTextField(
            maxLength: 200,
            maxLines: 7,
            hintText: "Describe what this event is about",
            controller: widget.eventDescController,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            "Visibility and Permissions",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: widget.changeVisibility,
              icon: Icon(
                widget.visibility ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            Text(
              widget.visibility ? "Public event" : "Private event",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: widget.changeCanInvite,
              icon: Icon(
                widget.canInvite ? Icons.meeting_room : Icons.door_back_door,
              ),
            ),
            Text(
              widget.canInvite
                  ? "Anyone can invite other users"
                  : "Only you can invite other users",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        ListTile(
          title: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              "Deadline for voting",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          subtitle: TextField(
            enabled: false,
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(
                Icons.calendar_today,
              ),
              border: InputBorder.none,
            ),
            controller: TextEditingController(
              text: DateFormat(Preferences.getBool("is24Hour")
                      ? "EEEE MMMM dd yyyy 'at' HH:mm"
                      : "EEEE MMMM dd yyyy 'at' hh:mm a")
                  .format(
                DateFormatter.string2DateTime(widget.deadlineController.text),
              ),
            ), //deadlineController,
          ),
          onTap: () async {
            showModalBottomSheet(
              useRootNavigator: true,
              isScrollControlled: true,
              context: context,
              builder: (context) => FractionallySizedBox(
                heightFactor: 0.4,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(left: 15, top: 0),
                            child: InkWell(
                              child: const Icon(
                                Icons.close,
                                size: 30,
                              ),
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  "This string will be passed back to the parent",
                                );
                              },
                            ),
                          ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8, top: 8),
                              alignment: Alignment.center,
                              child: Text(
                                "Select a deadline",
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(right: 15, top: 0),
                            child: InkWell(
                              onTap: () {
                                widget.setDeadline(_pickedDate);
                                List<String> toRemove = [];
                                widget.dates.forEach((day, slots) {
                                  slots.forEach((slot, _) {
                                    var startDateString =
                                        "${day.split(" ")[0]} ${slot.split("-")[0]}:00";
                                    DateTime startDate =
                                        DateFormatter.string2DateTime(
                                            startDateString);
                                    if (startDate.isBefore(_pickedDate)) {
                                      toRemove.add(day);
                                    }
                                  });
                                });
                                widget.removeDays(toRemove);
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.done,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: DateFormatter.string2DateTime(
                              widget.deadlineController.text),
                          minimumDate:
                              DateTime.now().add(const Duration(minutes: 30)),
                          minuteInterval: 5,
                          use24hFormat: true,
                          onDateTimeChanged: (pickedDate) {
                            _pickedDate = pickedDate;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
