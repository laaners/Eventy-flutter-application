import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepBasics extends StatelessWidget {
  final TextEditingController eventTitleController;
  final TextEditingController eventDescController;
  final TextEditingController deadlineController;

  final ValueChanged<DateTime> setDeadline;
  const StepBasics({
    super.key,
    required this.eventTitleController,
    required this.eventDescController,
    required this.deadlineController,
    required this.setDeadline,
  });

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
            controller: eventTitleController,
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
            controller: eventDescController,
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
            controller: deadlineController,
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
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour + 1,
                      (DateTime.now().minute % 5 * 5).toInt(),
                    ),
                    minimumDate: DateTime.now().add(const Duration(minutes: 1)),
                    minuteInterval: 5,
                    use24hFormat: true,
                    onDateTimeChanged: (pickedDate) {
                      setDeadline(pickedDate);
                    },
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
