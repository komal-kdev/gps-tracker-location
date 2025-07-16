import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const MaterialApp(home: DummyMapScreen()));

class DummyMapScreen extends StatefulWidget {
  const DummyMapScreen({super.key});

  @override
  State<DummyMapScreen> createState() => _DummyMapScreenState();
}

class _DummyMapScreenState extends State<DummyMapScreen> {
  final MapController _mapController = MapController();

  List<LatLng> allPoints = [];
  final List<LatLng> pathPoints = [];
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    try {
      final String data = await rootBundle.loadString('assets/latlong.json');
      final List<dynamic> jsonList = json.decode(data);

      allPoints = jsonList
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList();

     ("Loaded ${allPoints.length} points from JSON");

      if (allPoints.isNotEmpty) {
        pathPoints.add(allPoints[0]);
        setState(() {});
        _startTimer();
      }
    } catch (e) {
      (" Error loading JSON: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentIndex < allPoints.length - 1) {
        currentIndex++;
        setState(() {
          pathPoints.add(allPoints[currentIndex]);
        });
        _mapController.move(allPoints[currentIndex], 15);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool pathStarted = pathPoints.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Source & Destination Map")),
      body: !pathStarted
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pathPoints.first,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pathPoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    
                    Marker(
                      point: pathPoints.first,
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                    
                    
                   
if (allPoints.length > 1)
  Marker(
    point: allPoints.last,
    width: 60,
    height: 60,
    child: const Icon(Icons.location_city, color: Colors.red, size: 40),
  ),

                    
                    if (pathPoints.isNotEmpty)
                      Marker(
                        point: pathPoints.last,
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.circle, color: Colors.blue, size: 30),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
