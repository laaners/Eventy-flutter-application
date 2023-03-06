import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/themes/palette.dart';
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

  const StepBasics({
    super.key,
    required this.eventTitleController,
    required this.eventDescController,
    required this.deadlineController,
    required this.setDeadline,
    required this.dates,
    required this.removeDays,
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
          child: const Text(
            "Set the basic details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: const Text(
            "Title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
          child: const Text(
            "Description (optional)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
        ListTile(
          title: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: const Text(
              "Deadline for voting",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          subtitle: TextField(
            enabled: false,
            style: TextStyle(
              color: Provider.of<ThemeSwitch>(context, listen: false)
                  .themeData
                  .primaryColor,
            ),
            decoration: const InputDecoration(
              isDense: true,
              icon: Icon(
                Icons.calendar_today,
                color: Palette.greyColor,
              ),
              border: InputBorder.none,
            ),
            controller: TextEditingController(
              text: DateFormat("EEEE MMMM dd yyyy 'at' HH:mm").format(
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
                  color: Provider.of<ThemeSwitch>(context, listen: false)
                      .themeData
                      .scaffoldBackgroundColor,
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
                                margin:
                                    const EdgeInsets.only(bottom: 8, top: 8),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Select a deadline",
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
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
              ),
            );
          },
        ),
      ],
    );
  }
}
