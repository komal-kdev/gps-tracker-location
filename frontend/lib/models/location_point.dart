import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Local model class for location point
class LocationPoint {
  final double lat;
  final double lon;

  LocationPoint({required this.lat, required this.lon});
}

class LiveTrackingScreen extends StatefulWidget {
  final String trackerId;
  const LiveTrackingScreen({super.key, required this.trackerId});

  @override
  LiveTrackingScreenState createState() => LiveTrackingScreenState();
}

class LiveTrackingScreenState extends State<LiveTrackingScreen> {
  LocationPoint? currentLocation;
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
  }

  void _fetchLiveLocation() async {
    // Simulate live update with hardcoded location
    while (mounted) {
      final loc = LocationPoint(lat: 13.0827, lon: 80.2707); 
      setState(() => currentLocation = loc);
      mapController.move(LatLng(loc.lat, loc.lon), 16.0);
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(currentLocation!.lat, currentLocation!.lon),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(currentLocation!.lat, currentLocation!.lon),
                      width: 40,
                      height: 40,
                      child: Icon(Icons.gps_fixed, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
