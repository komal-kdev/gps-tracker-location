import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/geofence_zone_model.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  final mapController = MapController();
  List<LatLng> geofencePolygon = [];
  LatLng? currentLocation;
  bool isInside = true; 

  final notificationPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadGeofencePolygon();
    _fetchLiveLocation();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await notificationPlugin.initialize(settings);
  }

  Future<void> _showNotification(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'geofence_channel',
        'Geofence Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await notificationPlugin.show(0, title, body, details);
  }

  Future<void> _loadGeofencePolygon() async {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final uri = Uri.parse('http://$host:3001/geofence');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final zones = data.map((e) => GeofenceZone.fromJson(e)).toList();
      setState(() {
        geofencePolygon = zones.map((z) => LatLng(z.lat, z.lng)).toList();
      });
    }
  }

  Future<void> _fetchLiveLocation() async {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final uri = Uri.parse('http://$host:3001/locations');

    while (mounted) {
      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final lat = data['latitude'];
          final lng = data['longitude'];
          final position = LatLng(lat, lng);
          setState(() => currentLocation = position);
          _checkGeofence(position);
        }
      } catch (e) {
        (' Error: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _checkGeofence(LatLng position) {
    if (geofencePolygon.isEmpty) return;

    bool inside = _isPointInPolygon(position, geofencePolygon);
    if (inside != isInside) {
      isInside = inside;
      if (inside) {
        _showNotification("Geofence Enter", "You entered the geofence zone");
      } else {
        _showNotification("Geofence Exit", "You exited the geofence zone");
      }
    }
  }

 
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool odd = false;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < point.latitude &&
              polygon[j].latitude >= point.latitude ||
          polygon[j].latitude < point.latitude &&
              polygon[i].latitude >= point.latitude) &&
          (polygon[i].longitude +
                  (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) *
                      (polygon[j].longitude - polygon[i].longitude) <
              point.longitude)) {
        odd = !odd;
      }
      j = i;
    }
    return odd;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geofence Screen")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLocation!,
                initialZoom: 18,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.gps_fixed, color: Colors.blue, size: 40),
                    )
                  ],
                ),
                if (geofencePolygon.isNotEmpty)
                  CircleLayer(
  circles: [
    CircleMarker(
      point: geofencePolygon.first, 
      radius: 400,
      useRadiusInMeter: true,
      borderColor: Colors.redAccent,
      borderStrokeWidth: 6,
      color: Colors.redAccent.withAlpha(15),
    ),
  ],
),
            Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                  onPressed: () {
                    final zoom = mapController.camera.zoom;
                    final newZoom = (zoom + 1).clamp(3.0, 18.0);
                    mapController.move(mapController.camera.center, newZoom);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                  onPressed: () {
                    final zoom = mapController.camera.zoom;
                    final newZoom = (zoom - 1).clamp(3.0, 18.0);
                    mapController.move(mapController.camera.center, newZoom);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
