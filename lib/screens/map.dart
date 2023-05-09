import 'dart:async';

import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_event_location.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/event_location_collection.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_modal.dart';
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
          if (_liveUpdate) {
            _locationService.onLocationChanged.listen(
              (LocationData result) async {
                if (mounted) {
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
              },
            );
          }
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
    List<EventLocationCollection> locations =
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
          location.events.sort((a, b) => a["invited"] ? 1 : -1);
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
        upRightActions: [],
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

class EventLocationMarker extends StatelessWidget {
  final EventLocationCollection eventLocationDetails;
  final VoidCallback findNearbyEvents;
  const EventLocationMarker({
    super.key,
    required this.eventLocationDetails,
    required this.findNearbyEvents,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = eventLocationDetails.site
        .replaceFirst("${eventLocationDetails.site.split(", ")[0]}, ", "");
    return GestureDetector(
      onTap: () async {
        var ris = await MyModal.show(
          context: context,
          child: Column(
            children: [
              if (subtitle != eventLocationDetails.site)
                Container(
                  margin: const EdgeInsets.only(bottom: 0, top: 0, left: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ...eventLocationDetails.events.map((event) {
                return EventLocationTile(
                  eventId: event["eventId"],
                  eventName: event["eventName"],
                  invited: event["invited"] as bool,
                  public: event["public"] as bool,
                  locationBanner: event["locationBanner"],
                );
              }).toList()
            ],
          ),
          heightFactor: 0.85,
          doneCancelMode: true,
          onDone: () {},
          title: eventLocationDetails.site.split(",")[0],
        );
        if (ris != null) {
          String eventId = ris;
          findNearbyEvents();
          var curUid =
              // ignore: use_build_context_synchronously
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          Widget newScreen = PollEventScreen(pollEventId: eventId);
          // ignore: use_build_context_synchronously
          ris = await Navigator.of(context, rootNavigator: false).push(
            ScreenTransition(
              builder: (context) => newScreen,
            ),
          );
          if (ris == "delete_Event_$curUid") {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebaseEvent>(context, listen: false)
                .deleteEvent(
              context: context,
              eventId: eventId,
              showOutcome: true,
            );
          }
        }
      },
      child: const Icon(
        Icons.location_pin,
        color: Colors.blue,
        size: 40,
      ),
    );
  }
}

class EventLocationTile extends StatelessWidget {
  final String eventId;
  final String eventName;
  final bool public;
  final bool invited;
  final String locationBanner;
  const EventLocationTile({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.public,
    required this.invited,
    required this.locationBanner,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: LocationIcons.icons[locationBanner] != null
              ? Icon(LocationIcons.icons[locationBanner])
              : ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    "https://images.ygoprodeck.com/images/cards_cropped/42502956.jpg",
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress != null) {
                        return const Icon(Icons.place);
                      } else {
                        return child;
                      }
                      /*
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                        */
                    },
                  ),
                ),
        ),
        trailing:
            invited ? Icon(Icons.arrow_forward_ios_rounded) : Icon(Icons.login),
        /*
        */

        title: Text(
          eventName,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${public ? "Public" : "Private"} event, you are ${invited ? "partecipating" : "not partecipating"}",
        ),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          // if not invited and is a public event, add invite
          if (!invited && public) {
            bool confirmJoin = await MyAlertDialog.showAlertConfirmCancel(
              context: context,
              title: "Join this event?",
              content: "\"$eventName\" is public, you can join this event",
              trueButtonText: "Join",
            );
            if (!confirmJoin) return;
            LoadingOverlay.show(context);
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: eventId,
              inviteeId: curUid,
            );
            LoadingOverlay.hide(context);
          }
          Navigator.pop(context, eventId);
        },
      ),
    );
  }
}
