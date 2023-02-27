import 'package:dima_app/themes/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepSlots extends StatefulWidget {
  final List<DateTime> dates;
  final ValueChanged<DateTime> addDate;
  final ValueChanged<DateTime> removeDate;
  const StepSlots({
    super.key,
    required this.dates,
    required this.addDate,
    required this.removeDate,
  });

  @override
  State<StepSlots> createState() => _StepSlotsState();
}

class _StepSlotsState extends State<StepSlots> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0, top: 8, left: 16),
          alignment: Alignment.topLeft,
          child: const Text(
            "Select time slots",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: const Text(
            "Select the the time slots on which you are available for a meeting!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          margin:
              const EdgeInsets.only(top: 10, left: 20, right: 10, bottom: 10),
          child: const Text(
            "Skip this passage if you want to select manually the time for each single day",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Palette.greyColor,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              "text",
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "subtitle",
              overflow: TextOverflow.ellipsis,
            ),
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Palette.lightBGColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.videocam,
                color: Palette.greyColor,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.cancel,
              ),
              onPressed: () {
                print("vent");
              },
            ),
            onTap: () {
              print("tap event");
            },
          ),
        ),
      ],
    );
  }
}
