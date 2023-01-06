import 'package:dima_app/screens/event_create/select_location_address.dart';
import 'package:dima_app/screens/event_create/step_places.dart' as step_places;
import 'package:dima_app/screens/event_create/step_places.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectLocation extends StatefulWidget {
  final List<Location> locations;
  final ValueChanged<step_places.Location> setLocation;
  const SelectLocation(
      {super.key, required this.setLocation, required this.locations});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  TextEditingController locationNameController = TextEditingController();
  TextEditingController locationDescController = TextEditingController();
  TextEditingController locationAddrController = TextEditingController();
  List<String> locationSuggestions = [];
  String location = "Search Location";
  bool showMap = false;
  double lat = 0;
  double lon = 0;

  void checkFields() {
    if (locationNameController.text.isEmpty) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => const MyAlertDialog(
          title: "MISSING NAME",
          content: "You must give a name to the location",
        ),
      );
      return;
    }
    if (List<String>.from(widget.locations.map((obj) => obj.name))
            .contains(locationNameController.text) ||
        locationNameController.text == "Virtual meeting") {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => const MyAlertDialog(
          title: "DUPLICATE LOCATION",
          content: "You must give a different name to the location",
        ),
      );
      return;
    }
    if (locationAddrController.text.isEmpty) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => const MyAlertDialog(
          title: "MISSING ADDRESS",
          content: "You must give an address to the location",
        ),
      );
      return;
    }
    widget.setLocation(step_places.Location(
      locationNameController.text,
      locationDescController.text,
      locationAddrController.text,
      lat,
      lon,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                margin: const EdgeInsets.only(bottom: 8, top: 8),
                alignment: Alignment.center,
                child: const Text(
                  "New location for the event",
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
                onTap: checkFields,
                child: const Icon(
                  Icons.done,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Name",
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
                    maxLines: 1,
                    hintText: "Name of the Location",
                    controller: locationNameController,
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
                    maxLines: 6,
                    hintText:
                        "Add details and indications to reach this location",
                    controller: locationDescController,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8)),
                SelectLocationAddress(
                  controller: locationAddrController,
                  setAddress: (address) {
                    setState(() {
                      locationAddrController.text = address;
                    });
                  },
                  setCoor: (coor) {
                    setState(() {
                      lat = coor[0];
                      lon = coor[1];
                    });
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: MyButton(text: "Add location", onPressed: checkFields),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
