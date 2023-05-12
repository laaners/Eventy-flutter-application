import 'package:dima_app/models/location.dart';
import 'package:dima_app/screens/poll_create/components/select_location.dart';
import 'package:dima_app/screens/poll_create/components/select_virtual.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';

import '../../../models/location_icons.dart';

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
        Container(padding: const EdgeInsets.only(bottom: 8, top: 8)),
        PillBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Virtual meeting",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 5)),
              SizedBox(
                width: 50 * 1.4,
                height: 40 * 1.4,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: virtualMeeting,
                    onChanged: (value) {
                      if (value) {
                        MyModal.show(
                          context: context,
                          child: SelectVirtual(
                            defaultOptions: Location("", "", 1, 1, "videocam"),
                            locations: widget.locations,
                            addLocation: widget.addLocation,
                            removeLocation: widget.removeLocation,
                            setVirtualMeeting: (value) {
                              setState(() {
                                virtualMeeting = value;
                              });
                            },
                          ),
                          heightFactor: 0.85,
                          doneCancelMode: false,
                          onDone: () {},
                          title: "",
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
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: InkWell(
                onTap: () {
                  MyModal.show(
                    context: context,
                    child: SelectLocation(
                      locations: widget.locations,
                      addLocation: widget.addLocation,
                      removeLocation: widget.removeLocation,
                      defaultLocation:
                          Location("", "", 0, 0, "location_on_outlined"),
                    ),
                    heightFactor: 0.85,
                    doneCancelMode: false,
                    onDone: () {},
                    title: "",
                  );
                },
                child: const Icon(
                  Icons.add_location_alt,
                  size: 60,
                ),
              ),
            ),
            Text(
              "Add a location",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ]),
        ),
        if (widget.locations
            .map((x) => x.name)
            .contains("Virtual meeting")) //(virtualMeeting)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
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
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.videocam,
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
                MyModal.show(
                  context: context,
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
                  heightFactor: 0.85,
                  doneCancelMode: false,
                  onDone: () {},
                  title: "",
                );
              },
            ),
          ),
        ...widget.locations
            .where((_) => _.name != "Virtual meeting")
            .toList()
            .map((location) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: ListTile(
              title: Text(
                location.name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                location.site,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  LocationIcons.icons[location.icon],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  widget.removeLocation(location.name);
                },
              ),
              onTap: () {
                /*
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
                        defaultLocation: location,
                      ),
                    ),
                  ),
                );
                */
                MyModal.show(
                  context: context,
                  child: SelectLocation(
                    locations: widget.locations,
                    addLocation: widget.addLocation,
                    removeLocation: widget.removeLocation,
                    defaultLocation: location,
                  ),
                  heightFactor: 0.85,
                  doneCancelMode: false,
                  onDone: () {},
                  title: "",
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
