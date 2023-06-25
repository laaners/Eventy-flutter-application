import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Title",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          MyTextField(
            maxLength: 40,
            maxLines: 2,
            hintText: "What's the occasion?",
            controller: widget.eventTitleController,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Description (optional)",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          MyTextField(
            maxLength: 200,
            maxLines: 7,
            hintText: "Describe what this event is about",
            controller: widget.eventDescController,
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            minLeadingWidth: 0,
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
                text: DateFormat(Provider.of<ClockManager>(context).clockMode
                        ? "EEEE MMMM dd yyyy 'at' HH:mm"
                        : "EEEE MMMM dd yyyy 'at' hh:mm a")
                    .format(
                  DateFormatter.string2DateTime(widget.deadlineController.text),
                ),
              ), //deadlineController,
            ),
            onTap: () async {
              MyModal.show(
                context: context,
                heightFactor: 0.5,
                doneCancelMode: true,
                onDone: () {},
                child: MyModal(
                  heightFactor: 0.5,
                  doneCancelMode: true,
                  onDone: () {
                    widget.setDeadline(_pickedDate);
                    List<String> toRemove = [];
                    widget.dates.forEach((day, slots) {
                      slots.forEach((slot, _) {
                        var startDateString =
                            "${day.split(" ")[0]} ${slot.split("-")[0]}:00";
                        DateTime startDate =
                            DateFormatter.string2DateTime(startDateString);
                        if (startDate.isBefore(_pickedDate)) {
                          toRemove.add(day);
                        }
                      });
                    });
                    widget.removeDays(toRemove);
                    Navigator.pop(context);
                  },
                  child: Container(
                    transform: Matrix4.translationValues(0.0, -100.0, 0.0),
                    height: 500,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateFormatter.string2DateTime(
                          widget.deadlineController.text),
                      minimumDate:
                          DateTime.now().add(const Duration(minutes: 30)),
                      minuteInterval: 5,
                      use24hFormat:
                          Provider.of<ClockManager>(context, listen: false)
                              .clockMode,
                      onDateTimeChanged: (pickedDate) {
                        _pickedDate = pickedDate;
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
