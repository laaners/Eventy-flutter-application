import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  static const String route = '/marker_anchors';

  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() {
    return MapScreenState();
  }
}

class MapScreenState extends State<MapScreen> {
  late AnchorPos<dynamic> anchorPos;

  @override
  void initState() {
    super.initState();
    anchorPos = AnchorPos.align(AnchorAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        width: 80,
        height: 80,
        point: LatLng(51.5, -0.09),
        builder: (ctx) => const FlutterLogo(),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => const FlutterLogo(
          textColor: Colors.green,
        ),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => const FlutterLogo(textColor: Colors.purple),
        anchorPos: anchorPos,
      ),
    ];

    return Scaffold(
      appBar: const MyAppBar(
        upRightActions: [],
        title: 'Events Map',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Wrap(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {},
                    child: const Text('today'),
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
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
