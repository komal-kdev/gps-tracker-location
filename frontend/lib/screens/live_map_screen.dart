import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../models/location_point.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? deviceData; 

  const LiveTrackingScreen({
    super.key,
    this.deviceData,
  });

  @override
  State<LiveTrackingScreen> createState() => LiveTrackingScreenState();
}


class LiveTrackingScreenState extends State<LiveTrackingScreen> {
  LocationPoint? currentLocation;
  final mapController = MapController();
  

  @override
  void initState() {
    super.initState();
    _fetchLiveLocation();
  }
IconData getDeviceIcon(String type) {
  switch (type.toLowerCase().trim()) {
    case 'car':
      return Icons.directions_car;
    case 'bus':
      return Icons.directions_bus;
    case 'auto':
      return Icons.local_taxi;
    case 'scooty':
      return Icons.electric_scooter;
    case 'bike':
      return Icons.motorcycle;
    case 'lorry':
    case 'truck':
      return Icons.local_shipping;
    default:
      return Icons.gps_fixed;
  }
}



  void _fetchLiveLocation() async {
    while (mounted) {
      try {
        final loc = await _getLocationFromAPI();
        setState(() => currentLocation = loc);
        mapController.move(LatLng(loc.lat, loc.lon), mapController.camera.zoom);
      } catch (e) {
        debugPrint('Error fetching location: $e');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<LocationPoint> _getLocationFromAPI() async {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final uri = Uri.parse('http://$host:3001/locations');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LocationPoint(
        lat: data['latitude'],
        lon: data['longitude'],
      );
    } else {
      throw Exception('Failed to fetch location');
    }
  }

  @override
Widget build(BuildContext context) {
  final device = widget.deviceData;

  return Scaffold(
    body: currentLocation == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
  Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Name: ${device?['deviceName'] ?? device?['name'] ?? 'Unknown Device'}',
          style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Serial Number: ${device?['serialNumber'] ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 16),
        ),
       
        
        const SizedBox(height: 6),
      ],
    ),
  ),
],

                  ),
                ),
              ),

                        
                      
                    
                  
                
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                                currentLocation!.lat, currentLocation!.lon),
                            initialZoom: 18,
                            minZoom: 3,
                            maxZoom: 18,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                           TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
  userAgentPackageName: 'com.example.gps_tracker', 
),

                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(currentLocation!.lat,
                                      currentLocation!.lon),
                                  width: 40,
                                  height: 40,
                                  
                                  child:Icon(
  getDeviceIcon(device?['connectedDevice'] ?? ''),
  color: Colors.red,
  size: 40,
),


                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Zoom Out Button
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          heroTag: 'zoomOut',
                          backgroundColor: Colors.white,
                          mini: true,
                          child:
                              const Icon(Icons.zoom_out, color: Colors.black),
                          onPressed: () {
                            final zoom = mapController.camera.zoom;
                            final newZoom = (zoom - 1).clamp(3.0, 18.0);
                            mapController.move(
                                mapController.camera.center, newZoom);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
