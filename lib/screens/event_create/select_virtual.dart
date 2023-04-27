import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectVirtual extends StatefulWidget {
  final List<Location> locations;
  final ValueChanged<Location> addLocation;
  final ValueChanged<String> removeLocation;
  final ValueChanged<bool> setVirtualMeeting;
  final Location defaultOptions;
  const SelectVirtual({
    super.key,
    required this.addLocation,
    required this.removeLocation,
    required this.locations,
    required this.setVirtualMeeting,
    required this.defaultOptions,
  });

  @override
  State<SelectVirtual> createState() => _SelectVirtualState();
}

class _SelectVirtualState extends State<SelectVirtual> {
  TextEditingController locationAddrController = TextEditingController();
  List<String> locationSuggestions = [];
  String location = "Search Location";

  @override
  void initState() {
    super.initState();
    locationAddrController.text = widget.defaultOptions.site;
  }

  @override
  void dispose() {
    locationAddrController.dispose();
    super.dispose();
  }

  void checkFields() {
    widget.removeLocation("Virtual meeting");
    if (locationAddrController.text.isEmpty) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text("MISSING ROOM LINK"),
          content: const Text("Leave the virtual room link empty?"),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                widget.addLocation(Location(
                  "Virtual meeting",
                  locationAddrController.text,
                  0,
                  0,
                  "videocam",
                ));
                widget.setVirtualMeeting(true);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('YES'),
            ),
          ],
        ),
      );
      return;
    }
    widget.setVirtualMeeting(true);
    Navigator.pop(context);
    widget.addLocation(Location(
      "Virtual meeting",
      locationAddrController.text,
      0,
      0,
      "videocam",
    ));
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50 + 5),
            ),
            child: IconButton(
              iconSize: 100.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
              icon: Icon(
                LocationIcons.videocam,
              ),
            ),
          ),
        ),
        ListTile(
          title: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              "Virtual room link (optional)",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          subtitle: TextFormField(
            autofocus: false,
            controller: locationAddrController,
            decoration: InputDecoration(
              hintText: "Paste the link here",
              isDense: true,
              suffixIcon: IconButton(
                iconSize: 25,
                onPressed: () async {
                  await Clipboard.setData(
                      ClipboardData(text: locationAddrController.text));
                },
                icon: const Icon(Icons.link),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: MyButton(
            text: "Add virtual room",
            onPressed: checkFields,
          ),
        ),
      ],
    );
  }
}
