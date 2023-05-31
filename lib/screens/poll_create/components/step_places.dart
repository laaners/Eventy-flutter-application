import 'package:dima_app/models/location.dart';
import 'package:dima_app/screens/poll_create/components/select_location.dart';
import 'package:dima_app/screens/poll_create/components/select_virtual.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';

import '../../../models/location_icons.dart';
import '../../../widgets/location_tile.dart';

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
                          doneCancelMode: true,
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
          child: Column(
            children: [
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
                      doneCancelMode: true,
                      onDone: () {},
                      title: "",
                    );
                  },
                  child: const Icon(Icons.add_location_alt, size: 60),
                ),
              ),
              Text(
                "Add a location",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        if (widget.locations
            .map((x) => x.name)
            .contains("Virtual meeting")) //(virtualMeeting)
          Builder(builder: (context) {
            return LocationTile(
              leading: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const FittedBox(child: Icon(Icons.videocam)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  widget.removeLocation("Virtual meeting");
                  setState(() {
                    virtualMeeting = false;
                  });
                },
              ),
              title: "Virtual meeting",
              subtitle: widget.locations
                      .firstWhere((_) => _.name == "Virtual meeting")
                      .site
                      .isEmpty
                  ? "No link given"
                  : widget.locations
                      .firstWhere((_) => _.name == "Virtual meeting")
                      .site,
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
            );
          }),
        ...widget.locations
            .where((_) => _.name != "Virtual meeting")
            .toList()
            .map((location) {
          return LocationTile(
            leading: Container(
              height: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: FittedBox(child: Icon(LocationIcons.icons[location.icon])),
            ),
            title: location.name,
            subtitle: location.site,
            onTap: () {
              MyModal.show(
                context: context,
                child: SelectLocation(
                  locations: widget.locations,
                  addLocation: widget.addLocation,
                  removeLocation: widget.removeLocation,
                  defaultLocation: location,
                ),
                heightFactor: 0.85,
                doneCancelMode: true,
                onDone: () {},
                title: "",
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => widget.removeLocation(location.name),
            ),
          );
        }).toList(),
      ],
    );
  }
}
