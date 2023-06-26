import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/screens/poll_create/components/select_location_address.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
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
    bool ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: locationNameController.text.isEmpty,
      title: "Missing name",
      content: "You must give a name to the location",
    );
    if (ret) return;

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: locationNameController.text == "Virtual meeting",
      title: "Invalid name",
      content: "You must give a different name to the location",
    );
    if (ret) return;

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: locationAddrController.text.isEmpty,
      title: "Missing address",
      content: "You must give an address to the location",
    );
    if (ret) return;

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: lat == 0 && lon == 0,
      title: "Invalid address",
      content: "You must give a valid address to the location",
    );
    if (ret) return;

    showMap = false;
    Navigator.pop(context);
    widget.addLocation(Location(
      locationNameController.text,
      locationAddrController.text,
      lat,
      lon,
      locationIcon,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MyModal(
      doneCancelMode: true,
      onDone: checkFields,
      heightFactor: 0.85,
      title: "",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: LocationIcons.icons.entries
                .where((entry) => entry.value != LocationIcons.videocam)
                .map((entry) {
              return Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50 + 5),
                  color: LocationIcons.icons[locationIcon] == entry.value
                      ? Theme.of(context).focusColor
                      : Colors.transparent,
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
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Name",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          MyTextField(
            key: const Key("location_name_field"),
            maxLength: 40,
            maxLines: 1,
            hintText: "Name of the Location",
            controller: locationNameController,
          ),
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
        ],
      ),
    );
  }
}
