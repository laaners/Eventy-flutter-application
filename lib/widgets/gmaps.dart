import 'dart:convert';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GmapFromAddr extends StatefulWidget {
  final String address;
  const GmapFromAddr({super.key, required this.address});

  @override
  State<GmapFromAddr> createState() => GmapFromAddrState();
}

class GmapFromAddrState extends State<GmapFromAddr> {
  /*
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
*/
  double lat = 0;
  double lon = 0;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initPosition() async {
    var test = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search/${widget.address}?format=json&addressdetails=1&limit=1'),
    );
    var res = jsonDecode(test.body);
    if (res.length > 0) {
      setState(() {
        lat = double.parse(res[0]["lat"]);
        lon = double.parse(res[0]["lon"]);
        Marker marker = Marker(
          markerId: const MarkerId('place_name'),
          position: LatLng(lat, lon),
          // icon: BitmapDescriptor.,
          infoWindow: InfoWindow(
            title: widget.address,
            snippet: widget.address,
          ),
        );
        markers[const MarkerId('place_name')] = marker;
      });
    } else {
      setState(() {
        lat = 0;
        lon = 0;
        Marker marker = Marker(
          markerId: const MarkerId('place_name'),
          position: LatLng(lat, lon),
          // icon: BitmapDescriptor.,
          infoWindow: InfoWindow(
            title: widget.address,
            snippet: widget.address,
          ),
        );
        markers[const MarkerId('place_name')] = marker;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPosition();
  }

  @override
  Widget build(BuildContext context) {
    return lat == 0 && lon == 0
        ? const LoadingSpinner()
        : Container(
            height: 300,
            margin: const EdgeInsets.all(15),
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lon),
                zoom: 16.4746,
              ),
              markers: markers.values.toSet(),
            ),
          );
  }
}

class GmapFromCoor extends StatelessWidget {
  final String address;
  final double lat;
  final double lon;
  const GmapFromCoor({
    super.key,
    required this.lat,
    required this.lon,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(15),
      child: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lon),
          zoom: 16.4746,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('place_name'),
            position: LatLng(lat, lon),
            // icon: BitmapDescriptor.,
            infoWindow: InfoWindow(
              title: address,
              snippet: address,
            ),
          )
        },
      ),
    );
  }
}
