import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _sourceLatLng;
  LatLng? _destinationLatLng;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];

  late final StreamSubscription<Position> _positionSub;
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLiveLocation();

    // Listen to location updates in real-time
    _positionSub = Geolocator.getPositionStream().listen((Position position) {
       logger.i(" Live Location: ${position.latitude}, ${position.longitude}");
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _initLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 13.0);
    });
  }

  Future<void> _getCurrentLocationAsSource() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _sourceLatLng = LatLng(position.latitude, position.longitude);
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _getLatLngFromAddress(String address, bool isSource) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1';
    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'FlutterMapApp/1.0 (your@email.com)'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          if (isSource) {
            _sourceLatLng = LatLng(lat, lon);
          } else {
            _destinationLatLng = LatLng(lat, lon);
          }
        });
      }
    }
  }

  Future<void> _fetchRoute() async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${_sourceLatLng!.longitude},${_sourceLatLng!.latitude};${_destinationLatLng!.longitude},${_destinationLatLng!.latitude}?overview=full&geometries=polyline';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry'];
      setState(() {
        _routePoints = _decodePolyline(route);
        _mapController.move(_sourceLatLng!, 13.0);
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  void dispose() {
    _positionSub.cancel(); // Clean up location stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live OpenStreetMap with Routing'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_sourceController.text.trim().isEmpty) {
                      await _getCurrentLocationAsSource();
                    } else {
                      await _getLatLngFromAddress(
                          _sourceController.text.trim(), true);
                    }

                    if (_destinationController.text.trim().isNotEmpty) {
                      await _getLatLngFromAddress(
                          _destinationController.text.trim(), false);
                    }

                    if (_sourceLatLng != null && _destinationLatLng != null) {
                      await _fetchRoute();
                    }
                  },
                  child: const Text('Get Route'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(20.5937, 78.9629),
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.yourapp',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 8.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    if (_sourceLatLng != null)
                      Marker(
                        point: _sourceLatLng!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 25,
                        ),
                      ),
                    if (_destinationLatLng != null)
                      Marker(
                        point: _destinationLatLng!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
