import 'package:dima_app/screens/event_create/select_location.dart';
import 'package:dima_app/screens/event_create/select_virtual.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';

class Location {
  final String name;
  final String description;
  final String site;
  final double lat;
  final double lon;
  Location(this.name, this.description, this.site, this.lat, this.lon);

  @override
  String toString() {
    return 'Location(name: $name, description: $description, site: $site, lat: $lat, lon: $lon)';
  }
}

class StepPlaces extends StatefulWidget {
  final List<Location> locations;
  final ValueChanged<Location> addLocation;
  final ValueChanged<String> removeLocation;
  const StepPlaces({
    super.key,
    required this.locations,
    required this.addLocation,
    required this.removeLocation,
  });

  @override
  State<StepPlaces> createState() => _StepPlacesState();
}

class _StepPlacesState extends State<StepPlaces> {
  bool virtualMeeting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0, top: 8, left: 16),
          alignment: Alignment.topLeft,
          child: const Text(
            "Select the locations",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        PillBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Virtual meeting",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                width: 50 * 1.4,
                height: 40 * 1.4,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: virtualMeeting,
                    onChanged: (value) {
                      if (value) {
                        showModalBottomSheet(
                          useRootNavigator: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.85,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: SelectVirtual(
                                defaultOptions: Location("", "", "", 1, 1),
                                locations: widget.locations,
                                addLocation: widget.addLocation,
                                removeLocation: widget.removeLocation,
                                setVirtualMeeting: (value) {
                                  setState(() {
                                    virtualMeeting = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      } else {
                        widget.removeLocation("Virtual meeting");
                        setState(() {
                          virtualMeeting = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: ListTile(
            title: const Text(
              "Add a location",
              style: TextStyle(
                color: Palette.blueColor,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Palette.lightBGColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.add_location_alt,
                color: Palette.blueColor,
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.85,
                  child: Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    child: SelectLocation(
                      locations: widget.locations,
                      addLocation: widget.addLocation,
                      removeLocation: widget.removeLocation,
                      defaultLocation: Location("", "", "", 0, 0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.locations
            .map((x) => x.name)
            .contains("Virtual meeting")) //(virtualMeeting)
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
                widget.locations
                    .firstWhere((_) => _.name == "Virtual meeting")
                    .name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.locations
                        .firstWhere((_) => _.name == "Virtual meeting")
                        .site
                        .isEmpty
                    ? "No link given"
                    : widget.locations
                        .firstWhere((_) => _.name == "Virtual meeting")
                        .site,
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
                  widget.removeLocation("Virtual meeting");
                  setState(() {
                    virtualMeeting = false;
                  });
                },
              ),
              onTap: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      child: SelectVirtual(
                        defaultOptions: widget.locations
                            .firstWhere((_) => _.name == "Virtual meeting"),
                        locations: widget.locations,
                        addLocation: widget.addLocation,
                        removeLocation: widget.removeLocation,
                        setVirtualMeeting: (value) {
                          setState(() {
                            virtualMeeting = value;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: [const Text("ok")],
        ),
        for (var i = 0;
            i <
                widget.locations
                    .where((_) => _.name != "Virtual meeting")
                    .toList()
                    .length;
            i++)
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
                widget.locations
                    .where((_) => _.name != "Virtual meeting")
                    .toList()[i]
                    .name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.locations
                    .where((_) => _.name != "Virtual meeting")
                    .toList()[i]
                    .site,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Palette.lightBGColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Palette.greyColor,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  widget.removeLocation(widget.locations
                      .where((_) => _.name != "Virtual meeting")
                      .toList()[i]
                      .name);
                },
              ),
              onTap: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      child: SelectLocation(
                        locations: widget.locations,
                        addLocation: widget.addLocation,
                        removeLocation: widget.removeLocation,
                        defaultLocation: widget.locations
                            .where((_) => _.name != "Virtual meeting")
                            .toList()[i],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
