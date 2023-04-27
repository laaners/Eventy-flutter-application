import 'package:dima_app/screens/event_create/select_slot.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDaySlots extends StatefulWidget {
  final DateTime day;
  final Map<String, dynamic> dates;
  final ValueChanged<List<String>> addDate;
  final ValueChanged<List<String>> removeDate;
  final ValueChanged<List<String>> setSlot;
  const SelectDaySlots({
    super.key,
    required this.day,
    required this.dates,
    required this.addDate,
    required this.removeDate,
    required this.setSlot,
  });

  @override
  State<SelectDaySlots> createState() => _SelectDaySlotsState();
}

class _SelectDaySlotsState extends State<SelectDaySlots> {
  List<Widget> slotList = [];

  @override
  void initState() {
    super.initState();
    refreshSlotsList();
  }

  void refreshSlotsList() {
    setState(() {
      slotList = [];
      String dayString = DateFormatter.dateTime2String(widget.day);
      if (widget.dates.containsKey(dayString)) {
        List<dynamic> sortedSlots = widget.dates[dayString].keys.toList()
          ..sort();
        for (var k in sortedSlots) {
          slotList.add(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: ListTile(
                title: Text(
                  "${k.replaceAll('-', ' - ')}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.access_time_outlined,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    widget.removeDate([dayString, k]);
                    refreshSlotsList();
                  },
                ),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat f = DateFormat("MMMM dd, yyyy");
    var formattedDate = f.format(widget.day);
    String dayString = DateFormatter.dateTime2String(widget.day);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8, top: 8),
                alignment: Alignment.center,
                child: Text(
                  formattedDate,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: ListTile(
            title: const Text(
              "Add another time slot",
            ),
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.add_circle_outline,
              ),
            ),
            onTap: () async {
              /*
              */
              await showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.4,
                  child: SelectSlot(
                    dayString: dayString,
                    setSlot: widget.setSlot,
                  ),
                ),
              );
              refreshSlotsList();
            },
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              children: [
                if (!widget.dates.containsKey(dayString))
                  const Center(
                    child: Text(
                      "No time slots selected for this day",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                if (widget.dates.containsKey(dayString)) ...slotList,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
