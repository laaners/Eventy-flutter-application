import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  TextEditingController locationNameController = TextEditingController();
  TextEditingController locationDescController = TextEditingController();
  TextEditingController locationAddrController = TextEditingController();
  List<String> locationSuggestions = [];
  String location = "Search Location";

  @override
  void initState() {
    super.initState();
    locationNameController.text = "Virtual meeting";
    locationDescController.text = widget.defaultOptions.description;
    locationAddrController.text = widget.defaultOptions.site;
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
                  locationNameController.text,
                  locationDescController.text,
                  locationAddrController.text,
                  0,
                  0,
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
      locationNameController.text,
      locationDescController.text,
      locationAddrController.text,
      0,
      0,
    ));
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
                  "Virtual meeting details",
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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Palette.greyColor),
                    ),
                    child: TextFormField(
                      enabled: false,
                      autofocus: false,
                      controller: locationNameController,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: null, // widget.maxLines,
                      style: TextStyle(
                        color: Provider.of<ThemeSwitch>(context)
                            .themeData
                            .primaryColor,
                      ),
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      maxLength: 40,
                    ),
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
                    hintText: "Virtual room on the ... platform",
                    controller: locationDescController,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8)),
                ListTile(
                  title: const Text(
                    "Virtual room link (optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  horizontalTitleGap: 0,
                  trailing: IconButton(
                    iconSize: 25,
                    onPressed: () {
                      setState(() {
                        locationAddrController.text = "";
                      });
                    },
                    icon: Icon(locationAddrController.text.isEmpty
                        ? Icons.link
                        : Icons.cancel),
                  ),
                  subtitle: TextField(
                    autofocus: false,
                    controller: locationAddrController,
                    decoration:
                        const InputDecoration(hintText: "Paste the link here"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: MyButton(
                    text: "Add virtual room",
                    onPressed: checkFields,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
