import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
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

  void checkFields() async {
    widget.removeLocation("Virtual meeting");
    if (locationAddrController.text.isEmpty) {
      bool ris = await MyAlertDialog.showAlertConfirmCancel(
        context: context,
        title: "Missing room link",
        content: "Leave the virtual room link empty?",
        trueButtonText: "Confirm",
      );

      if (ris) {
        // left empty
        widget.addLocation(Location(
          "Virtual meeting",
          locationAddrController.text,
          0,
          0,
          "videocam",
        ));
        widget.setVirtualMeeting(true);
      } else {
        return;
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
    return MyModal(
      doneCancelMode: true,
      onDone: checkFields,
      heightFactor: 0.85,
      title: "",
      child: Column(
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
            contentPadding: const EdgeInsets.all(0),
            minLeadingWidth: 0,
            horizontalTitleGap: 0,
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
        ],
      ),
    );
  }
}
