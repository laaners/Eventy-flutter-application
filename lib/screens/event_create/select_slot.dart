import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectSlot extends StatefulWidget {
  final ValueChanged<List<String>> setSlot;
  const SelectSlot({super.key, required this.setSlot});

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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.clear,
                ),
              ),
              const Text(
                'Add a time slot',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
              ),
              IconButton(
                onPressed: () {
                  DateFormat f = DateFormat("HH:mm");
                  widget.setSlot([
                    f.format(_startDate),
                    f.format(_endDate),
                  ]);
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.done,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Select start time',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: _startDate,
                        minuteInterval: 5,
                        use24hFormat: true,
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
                  children: [
                    const Text(
                      'Select end time',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: _endDate,
                        minuteInterval: 5,
                        use24hFormat: true,
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
        ),
      ],
    );
  }
}
