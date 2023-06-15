import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/poll_create/components/select_slot.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDaySlots extends StatefulWidget {
  final DateTime day;
  final Map<String, dynamic> dates;
  final ValueChanged<List<String>> addDate;
  final ValueChanged<List<String>> removeDate;
  final Function removeEmpty;
  final ValueChanged<List<String>> setSlot;
  const SelectDaySlots({
    super.key,
    required this.day,
    required this.dates,
    required this.addDate,
    required this.removeDate,
    required this.setSlot,
    required this.removeEmpty,
  });

  @override
  State<SelectDaySlots> createState() => _SelectDaySlotsState();
}

class _SelectDaySlotsState extends State<SelectDaySlots> {
  @override
  Widget build(BuildContext context) {
    String dayString = DateFormatter.dateTime2String(widget.day);
    return Column(
      children: [
        MyListTile(
          leading: MyListTile.leadingIcon(
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          title: "Add another time slot",
          onTap: () async {
            await MyModal.show(
              context: context,
              heightFactor: 0.5,
              doneCancelMode: true,
              onDone: () {},
              child: SelectSlot(
                dayString: dayString,
                setSlot: widget.setSlot,
              ),
            );
            setState(() {});
          },
        ),
        widget.dates.containsKey(dayString)
            ? Scrollbar(
                child: ListView.builder(
                  controller: ScrollController(),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.dates[dayString].keys.length,
                  itemBuilder: (context, index) {
                    var k = widget.dates[dayString].keys.toList()[index];
                    var start = k.split("-")[0];
                    var end = k.split("-")[1];
                    if (!Preferences.getBool('is24Hour')) {
                      start =
                          "${DateFormat("hh:mm a").format(DateFormatter.string2DateTime("2000-01-01 $start:00"))} ";
                      end =
                          " ${DateFormat("hh:mm a").format(DateFormatter.string2DateTime("2000-01-01 $end:00"))}";
                    }
                    return MyListTile(
                      leading: MyListTile.leadingIcon(
                        icon: const Icon(Icons.access_time_outlined),
                      ),
                      title: "$start - $end",
                      trailing: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          widget.removeDate([dayString, k]);
                          widget.removeEmpty();
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              )
            : const EmptyList(emptyMsg: "No time slots selected for this day"),
      ],
    );
  }
}
