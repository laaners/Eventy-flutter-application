import 'dart:async';

import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_event_location.dart';
import 'package:dima_app/server/tables/event_location_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

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
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;

                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                    LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    _mapController.zoom,
                  );
                }
              });
            }
          });
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

    markers = [
      // Live location marker
      Marker(
        width: 80,
        height: 80,
        point: currentLatLng,
        builder: (ctx) => const Icon(
          Icons.location_pin,
          size: 35,
          color: Colors.red,
        ),
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(51.5, -0.09),
        builder: (ctx) => const Icon(Icons.location_pin, color: Colors.blue),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => const Icon(Icons.location_pin, color: Colors.blue),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => const Icon(Icons.location_pin, color: Colors.blue),
        anchorPos: anchorPos,
      ),
    ];

    return;
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

    print("rebuild");a
    return Scaffold(
      appBar: const MyAppBar(
        upRightActions: [],
        title: 'Events Map',
      ),
      body: ResponsiveWrapper(
        child: false
            ? Text("ok")
            : FutureBuilder(
                future: _future,
                builder: (
                  BuildContext context,
                  AsyncSnapshot snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingSpinner();
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Wrap(
                            children: <Widget>[
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
                                      _mapController.move(currentLatLng, 13);
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
                                  });
                                }
                              },
                              onPositionChanged: (position, hasGesture) async {
                                if (_debounce?.isActive ?? false)
                                  _debounce?.cancel();
                                _debounce =
                                    Timer(const Duration(milliseconds: 300),
                                        () async {
                                  List<EventLocationCollection> locations =
                                      await Provider.of<FirebaseEventLocation>(
                                              context,
                                              listen: false)
                                          .getEventsFromLocation(
                                    east: _mapController.bounds!.east,
                                    west: _mapController.bounds!.west,
                                    north: _mapController.bounds!.north,
                                    south: _mapController.bounds!.south,
                                  );
                                  setState(() {
                                    markers = [];
                                    markers = [
                                      // Live location marker
                                      Marker(
                                        width: 80,
                                        height: 80,
                                        point: currentLatLng,
                                        builder: (ctx) => const Icon(
                                          Icons.location_pin,
                                          size: 35,
                                          color: Colors.black,
                                        ),
                                      ),
                                      ...locations.map((location) {
                                        return Marker(
                                          width: 800,
                                          height: 800,
                                          point: LatLng(
                                              location.lat, location.lon),
                                          builder: (ctx) => const Icon(
                                            Icons.location_pin,
                                            color: Colors.blue,
                                            size: 50,
                                          ),
                                          anchorPos: anchorPos,
                                        );
                                      }).toList(),
                                    ];
                                  });
                                  print(locations);
                                  print("should new markers");
                                });
                              },
                              maxZoom: 18,
                              center: LatLng(
                                currentLatLng.latitude,
                                currentLatLng.longitude,
                              ),
                              zoom: 16.4746,
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
                        if (_mapIsReady)
                          Column(
                            children: [
                              Text(
                                "${_mapController.bounds!.center.latitude}_${_mapController.bounds!.center.longitude}",
                              ),
                              Text(
                                "${_mapController.bounds!.west}_${_mapController.bounds!.east}",
                              ),
                              Text(
                                "${_mapController.bounds!.south}_${_mapController.bounds!.north}",
                              ),
                            ],
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
