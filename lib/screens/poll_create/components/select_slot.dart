import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectSlot extends StatefulWidget {
  final String dayString;
  final ValueChanged<List<String>> setSlot;
  const SelectSlot({super.key, required this.setSlot, required this.dayString});

  @override
  State<SelectSlot> createState() => _SelectSlotState();
}

class _SelectSlotState extends State<SelectSlot> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour + 1,
      (DateTime.now().minute % 5 * 5).toInt(),
    );

    _endDate = _startDate.add(const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return MyModal.modalWidget(
      context: context,
      heightFactor: 0.5,
      doneCancelMode: true,
      onDone: () {
        DateFormat f = DateFormat("HH:mm");
        widget.setSlot(
            [f.format(_startDate), f.format(_endDate), widget.dayString]);
        Navigator.of(context).pop();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Start Time',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  height: 380,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _startDate,
                    minuteInterval: 5,
                    use24hFormat: Preferences.getBool("is24Hour"),
                    onDateTimeChanged: (pickedDate) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'End Time',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  height: 380,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _endDate,
                    minuteInterval: 5,
                    use24hFormat: Preferences.getBool("is24Hour"),
                    onDateTimeChanged: (pickedDate) {
                      setState(() {
                        _endDate = pickedDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
