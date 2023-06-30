import 'dart:async';
import 'dart:convert';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SelectLocationAddress extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> setAddress;
  final ValueChanged<List<double>> setCoor;
  final Location defaultLocation;
  final FocusNode focusNode;
  const SelectLocationAddress({
    super.key,
    required this.controller,
    required this.setAddress,
    required this.setCoor,
    required this.defaultLocation,
    required this.focusNode,
  });

  @override
  State<SelectLocationAddress> createState() => _SelectLocationAddressState();
}

class _SelectLocationAddressState extends State<SelectLocationAddress> {
  List<Map<String, dynamic>> locationSuggestions = [];
  Timer? _debounce;
  bool loadingLocations = false;
  bool showMap = false;
  double lat = 0;
  double lon = 0;

  String nullableProperty(obj, property) {
    return (obj.containsKey(property) ? obj[property].toString() : "");
  }

  @override
  void initState() {
    super.initState();
    if (widget.defaultLocation.lat != 0 && widget.defaultLocation.lon != 0) {
      showMap = true;
      lat = widget.defaultLocation.lat;
      lon = widget.defaultLocation.lon;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    showMap = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          alignment: Alignment.topLeft,
          child: Text(
            "Address",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        SearchTile(
          key: const Key("location_addr_field"),
          controller: widget.controller,
          focusNode: widget.focusNode,
          hintText: "Search here",
          onChanged: (text) async {
            if (text.isEmpty) {
              setState(() {
                showMap = false;
                locationSuggestions = [];
                loadingLocations = false;
              });
              return;
            }
            // https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), () async {
              // var countrycode = WidgetsBinding.instance.window.locale.countryCode;
              // &countrycodes=$countrycode
              setState(() {
                loadingLocations = true;
              });
              try {
                var test = await http.get(
                  Uri.parse(
                      'https://nominatim.openstreetmap.org/search/$text?format=json&addressdetails=1&limit=10'),
                );
                var res = jsonDecode(test.body);
                if (res.length > 0) {
                  setState(() {
                    showMap = false;
                    locationSuggestions = List<Map<String, dynamic>>.from(
                      res.map((obj) {
                        String city = nullableProperty(obj["address"], "city");
                        String state =
                            nullableProperty(obj["address"], "state");
                        String country =
                            nullableProperty(obj["address"], "country");
                        String subtitle = "$city, $state $country";
                        subtitle = subtitle.substring(0, 2) == ", "
                            ? subtitle.substring(2)
                            : subtitle;

                        String houseNumber =
                            nullableProperty(obj["address"], "house_number");
                        houseNumber = houseNumber == "" ? "" : ", $houseNumber";
                        String title = nullableProperty(obj["address"], "road");
                        title = title == ""
                            ? obj["display_name"]
                            : "$title$houseNumber";
                        var newObj = {
                          "title": title,
                          "subtitle": subtitle,
                          "lat": double.parse(obj["lat"]),
                          "lon": double.parse(obj["lon"]),
                        };
                        return newObj;
                      }),
                    );
                    loadingLocations = false;
                  });
                } else {
                  setState(() {
                    showMap = false;
                    locationSuggestions = [];
                    loadingLocations = false;
                    widget.setCoor([0, 0]);
                  });
                }
              } on Exception catch (e) {
                // ignore: avoid_print
                print("Nominatim error: $e");
                setState(() {
                  showMap = false;
                  locationSuggestions = [];
                  loadingLocations = false;
                });
              }
            });
          },
          emptySearch: () {
            setState(() {
              widget.setAddress("");
              locationSuggestions = [];
              showMap = false;
            });
          },
        ),
        Container(padding: const EdgeInsets.only(bottom: 8)),
        if (showMap)
          MapFromCoor(lat: lat, lon: lon, address: widget.controller.text)
        else
          loadingLocations
              ? const LoadingLogo()
              : Column(
                  children: [
                    for (var i = 0; i < locationSuggestions.length; i++)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            locationSuggestions[i]["title"]!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            locationSuggestions[i]["subtitle"]!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.north_west),
                          onTap: () {
                            setState(() {
                              widget
                                  .setAddress(locationSuggestions[i]["title"]!);
                              lat = locationSuggestions[i]["lat"];
                              lon = locationSuggestions[i]["lon"];
                              widget.setCoor([lat, lon]);
                              locationSuggestions = [];
                              showMap = true;
                              loadingLocations = false;
                            });
                          },
                        ),
                      ),
                  ],
                )
      ],
    );
  }
}
