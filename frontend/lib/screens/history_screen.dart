import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPoint {
  final double lat;
  final double lon;
  final DateTime timestamp;

  LocationPoint({
    required this.lat,
    required this.lon,
    required this.timestamp,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      lat: json['latitude'].toDouble(),
      lon: json['longitude'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;
  List<LocationPoint> _historyPoints = [];

  
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    _fromDate = DateTime.now().subtract(const Duration(days: 7));
    _toDate = DateTime.now();

    _fromDateController = TextEditingController(text: _formatDate(_fromDate!));
    _toDateController = TextEditingController(text: _formatDate(_toDate!));

    _submit();
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _toApiDate(DateTime date) {
    return _formatDate(date);
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate ? _fromDate! : _toDate!;
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          _fromDateController.text = _formatDate(picked);
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = _fromDate;
            _toDateController.text = _formatDate(_toDate!);
          }
        } else {
          if (_fromDate != null && picked.isBefore(_fromDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("To Date can't be before From Date")),
            );
            return;
          }
          _toDate = picked;
          _toDateController.text = _formatDate(picked);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_fromDate == null || _toDate == null) return;

    final uri = Uri.http(
      "192.168.1.7:3001",
      "/locations/history",
      {
        "from": _toApiDate(_fromDate!),
        "to": _toApiDate(_toDate!),
      },
    );

    try {
      final response = await http.get(uri);
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = jsonDecode(response.body);
        final points = data.map((e) => LocationPoint.fromJson(e)).toList();
        debugPrint("Fetched ${points.length} location points");

        setState(() {
          _historyPoints = points;
        });

        if (points.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No location data found in this range")),
          );
        }
      } else {
        throw Exception("Failed to load history");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastPoint = _historyPoints.isNotEmpty
        ? LatLng(_historyPoints.last.lat, _historyPoints.last.lon)
        : const LatLng(20.5937, 78.9629); 

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDateField(
                      label: 'From',
                      controller: _fromDateController,
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(width: 16),
                    _buildDateField(
                      label: 'To',
                      controller: _toDateController,
                      onTap: () => _selectDate(context, false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildWhiteButton(text: "Submit", onTap: _submit),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController, 
                  options: MapOptions(
                    initialCenter: lastPoint,
                    initialZoom: _historyPoints.isNotEmpty ? 15.0 : 5.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.historyscreen',
                    ),
                    if (_historyPoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _historyPoints.map((p) => LatLng(p.lat, p.lon)).toList(),
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _historyPoints.map((point) => Marker(
                        point: LatLng(point.lat, point.lon),
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                      )).toList(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'DD/MM/YYYY',
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
