import 'package:dima_app/screens/event_create/select_location_address.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectLocation extends StatefulWidget {
  final List<Location> locations;
  final ValueChanged<Location> addLocation;
  final ValueChanged<String> removeLocation;
  final Location defaultLocation;
  const SelectLocation({
    super.key,
    required this.addLocation,
    required this.removeLocation,
    required this.locations,
    required this.defaultLocation,
  });

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  TextEditingController locationNameController = TextEditingController();
  TextEditingController locationAddrController = TextEditingController();
  List<String> locationSuggestions = [];
  String location = "Search Location";
  bool showMap = false;
  double lat = 0;
  double lon = 0;
  FocusNode focusNode = FocusNode();
  String locationIcon = "location_on_outlined";

  @override
  void initState() {
    super.initState();
    locationNameController.text = widget.defaultLocation.name;
    locationAddrController.text = widget.defaultLocation.site;
    lat = widget.defaultLocation.lat;
    lon = widget.defaultLocation.lon;
    locationIcon = widget.defaultLocation.icon;
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    showMap = false;
    focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    debugPrint("\t\t\tFocus: ${focusNode.hasFocus.toString()}");
  }

  void checkFields() {
    widget.removeLocation(widget.defaultLocation.name);
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
    if (locationNameController.text == "Virtual meeting") {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => const MyAlertDialog(
          title: "INVALID NAME",
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
    if (lat == 0 && lon == 0) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => const MyAlertDialog(
          title: "INVALID ADDRESS",
          content: "You must give a valid address to the location",
        ),
      );
      return;
    }
    showMap = false;
    Navigator.pop(context);
    widget.addLocation(Location(
      locationNameController.text,
      locationAddrController.text,
      lat,
      lon,
      locationIcon,
    ));
    print(widget.locations);
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  reverseDuration: const Duration(milliseconds: 1000),
                  child: false
                      ? Container()
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: LocationIcons.icons.entries
                                  .where((entry) =>
                                      entry.value != LocationIcons.videocam)
                                  .map((entry) {
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50 + 5),
                                  ),
                                  child: IconButton(
                                    iconSize: 50.0,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        locationIcon = entry.key;
                                      });
                                    },
                                    icon: Icon(
                                      entry.value,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8, top: 8, left: 15),
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: MyTextField(
                                maxLength: 40,
                                maxLines: 1,
                                hintText: "Name of the Location",
                                controller: locationNameController,
                              ),
                            ),
                          ],
                        ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8)),
                SelectLocationAddress(
                  defaultLocation: widget.defaultLocation,
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
                  focusNode: focusNode,
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
