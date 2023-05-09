import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapFromCoor extends StatefulWidget {
  final String address;
  final double lat;
  final double lon;
  const MapFromCoor({
    super.key,
    required this.lat,
    required this.lon,
    required this.address,
  });

  @override
  State<MapFromCoor> createState() => _MapFromCoorState();
}

class _MapFromCoorState extends State<MapFromCoor> {
  late AnchorPos<dynamic> anchorPos;

  @override
  void initState() {
    super.initState();
    anchorPos = AnchorPos.align(AnchorAlign.center);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("ok");
    return Container(
      height: 300,
      margin: const EdgeInsets.all(15),
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.lat, widget.lon),
          zoom: 16.4746,
          maxZoom: 18,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.drag,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: LatLng(widget.lat, widget.lon),
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    print("ok");
                  },
                  child: const Icon(
                    Icons.place,
                    size: 35,
                  ),
                ),
                anchorPos: anchorPos,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
