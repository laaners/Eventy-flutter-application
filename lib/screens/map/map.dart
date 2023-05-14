import 'dart:async';
import 'package:dima_app/models/event_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_event_location.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'components/event_location_marker.dart';
import 'components/event_search_by_name.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void>? _future;
  LocationData? _currentLocation;
  late final MapController _mapController;
  AnchorPos<dynamic> anchorPos = AnchorPos.align(AnchorAlign.center);

  bool _liveUpdate = false;
  bool _permission = false;
  bool _mapIsReady = false;
  Timer? _debounce;

  List<Marker> markers = [];
  LatLng currentLatLng = LatLng(45.4855182, 9.1473723);
  Marker currentMarker() => Marker(
        width: 80,
        height: 80,
        point: currentLatLng,
        builder: (ctx) => GestureDetector(
          onTap: () {
            MyAlertDialog.showAlertIfCondition(
              context: context,
              condition: true,
              title: "This your location!",
              content: "Live update is ${_liveUpdate ? "enabled" : "disabled"}",
            );
            /*
            _mapController.move(currentLatLng, 17);
            */
          },
          child: const Icon(
            Icons.location_pin,
            size: 40,
            color: Colors.red,
          ),
        ),
      );

  String? _serviceError = '';

  // Allowed gestures on map
  int interActiveFlags = InteractiveFlag.pinchZoom |
      InteractiveFlag.doubleTapZoom |
      InteractiveFlag.drag;

  final Location _locationService = Location();

  Future<void> initLocationService() async {
    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        final permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();

          await _locationService.changeSettings(
            accuracy: LocationAccuracy.high,
            interval: 1000,
          );

          _currentLocation = location;

          // If Live Update is enabled, move map center
          _locationService.onLocationChanged.listen(
            (LocationData result) async {
              if (mounted) {
                if (_liveUpdate) {
                  setState(() {
                    _currentLocation = result;
                    _mapController.move(
                      LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      _mapController.zoom,
                    );
                  });
                }
              }
            },
          );
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          await initLocationService();
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }

    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    if (_currentLocation != null) {
      currentLatLng = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
    } else {
      currentLatLng = LatLng(45.4855182, 9.1473723);
    }

    markers = [currentMarker()];

    return;
  }

  Future<void> findNearbyEvents() async {
    List<EventLocationModel> locations =
        await Provider.of<FirebaseEventLocation>(context, listen: false)
            .getEventsFromBounds(
      context: context,
      east: _mapController.bounds!.east,
      west: _mapController.bounds!.west,
      north: _mapController.bounds!.north,
      south: _mapController.bounds!.south,
    );
    setState(() {
      markers = [];
      markers = [
        ...locations.map((location) {
          location.events.sort((a, b) => "${a.date} ${a.start}-${a.end}"
              .compareTo("${b.date} ${b.start}-${b.end}"));
          location.events.sort((a, b) => a.invited ? 1 : -1);
          return Marker(
            width: 80,
            height: 80,
            point: LatLng(location.lat, location.lon),
            builder: (ctx) => EventLocationMarker(
              eventLocationDetails: location,
              findNearbyEvents: findNearbyEvents,
            ),
            anchorPos: anchorPos,
          );
        }).toList(),
        currentMarker()
      ];
    });
  }

  Future<void> focusOnCurrentLocation() async {
    if (_mapIsReady) {
      LocationData locationData = await _locationService.getLocation();
      setState(() {
        _currentLocation = locationData;
        currentLatLng = LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
      });
      _mapController.move(
        currentLatLng,
        _mapController.zoom,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _future = initLocationService();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("rebuild map");
    return Scaffold(
      appBar: const MyAppBar(
        upRightActions: [EventSearchByName()],
        title: 'Events Map',
      ),
      body: ResponsiveWrapper(
        child: FutureBuilder(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingLogo();
            }
            if (snapshot.hasError) {
              Future.microtask(() {
                Navigator.of(context, rootNavigator: false).push(
                  ScreenTransition(
                    builder: (context) => ErrorScreen(
                      errorMsg: snapshot.error.toString(),
                    ),
                  ),
                );
              });
              return Container();
            }
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  if (_mapIsReady)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Wrap(
                        children: [
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                _future = initLocationService();
                              });
                            },
                            child: const Text('permission'),
                          ),
                          // Live location button
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                _liveUpdate = !_liveUpdate;

                                if (_liveUpdate) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Message on live update'),
                                  ));
                                  // center map on current location
                                  _mapController.move(
                                    currentLatLng,
                                    _mapController.zoom,
                                  );
                                }
                              });
                            },
                            child: const Text("near you"),
                          ),
                          MaterialButton(
                            onPressed: () {},
                            child: const Text('followers'),
                          ),
                          MaterialButton(
                            onPressed: () {},
                            child: const Text('all'),
                          ),
                          Text("is live $_liveUpdate"),
                          MaterialButton(
                            onPressed: () async {
                              await focusOnCurrentLocation();
                            },
                            child: const Text("test cur loc"),
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                currentLatLng = LatLng(45.49, 9.19);
                                _mapController.move(
                                  LatLng(45.49, 9.19),
                                  _mapController.zoom,
                                );
                              });
                            },
                            child: const Text("test near"),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              int curNumEvents = markers.length;
                              for (int i = 0; i < 10; i++) {
                                if (_mapController.zoom <= 5) {
                                  MyAlertDialog.showAlertIfCondition(
                                    context: context,
                                    condition: true,
                                    title: "No nearby events found",
                                    content:
                                        "Stopping the search, the closest event is too far!",
                                  );
                                  return;
                                }
                                // while (markers.length <= 1) {
                                setState(() {
                                  _mapController.move(
                                    currentLatLng,
                                    _mapController.zoom - 0.5,
                                  );
                                });
                                await findNearbyEvents();
                                if (markers.length > curNumEvents) {
                                  return;
                                }
                              }
                              // ignore: use_build_context_synchronously
                              MyAlertDialog.showAlertIfCondition(
                                context: context,
                                condition: true,
                                title: "No nearby events found",
                                content:
                                    "Use the nearby function again to look for more even distant events!",
                              );
                              return;
                            },
                            child: const Text("test zoom (nearby search)"),
                          ),
                        ],
                      ),
                    ),
                  Flexible(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        onMapReady: () {
                          if (!_mapIsReady) {
                            setState(() {
                              _mapIsReady = true;
                              _mapController.move(
                                LatLng(
                                  _currentLocation!.latitude!,
                                  _currentLocation!.longitude!,
                                ),
                                _mapController.zoom,
                              );
                              findNearbyEvents();
                            });
                          }
                        },
                        onPositionChanged: (position, hasGesture) async {
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 300),
                            () async => await findNearbyEvents(),
                          );
                        },
                        maxZoom: 18,
                        minZoom: 4,
                        center: LatLng(
                          currentLatLng.latitude,
                          currentLatLng.longitude,
                        ),
                        zoom: 17,
                        interactiveFlags: interActiveFlags,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
