import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gps_tracker/screens/live_map_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gps_tracker/screens/add_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<dynamic> _deviceList = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/devices_data.json');
  }

  Future<void> _loadDevices() async {
    final file = await _localFile;
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode([]));
    }
    final contents = await file.readAsString();
    setState(() {
      _deviceList = jsonDecode(contents);
    });
  }

  Future<void> _saveDevices() async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(_deviceList));
  }

  void _toggleFavorite(int index) async {
    setState(() {
      _deviceList[index]['isFavorite'] = !(_deviceList[index]['isFavorite'] ?? false);
    });
    await _saveDevices();
  }

  void _deleteDevice(int index) async {
    final deviceName = _deviceList[index]['deviceName'] ?? _deviceList[index]['name'] ?? 'this device';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Device"),
          content: Text("Are you sure you want to delete \"$deviceName\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed == true) {
      setState(() {
        _deviceList.removeAt(index);
      });
      await _saveDevices();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "$deviceName"')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
              );
              await _loadDevices();
              
            },
          ),
        ],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return index == 0 ? _buildGroupCard(filled: true) : _buildGroupCard();
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _deviceList.isEmpty
                  ? const Center(child: Text("No devices found."))
                  : ListView.builder(
                      itemCount: _deviceList.length,
                      itemBuilder: (context, index) {
                        final device = _deviceList[index];
                        final isFavorite = device['isFavorite'] ?? false;

                        final serialNumber = device['serialNumber'] ?? '';
                        final connectedDevice = device['connectedDevice'] ?? 'N/A';

                        return GestureDetector(
                          onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LiveTrackingScreen(
        deviceData: device, 
      ),
    ),
  );
},
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(10),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            device['deviceName'] ?? device['name'] ?? 'Unnamed',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Nick Name: ${device['nickName'] ?? device['nickname'] ?? 'N/A'}"),
                                      Text("Serial: $serialNumber"),
                                      Text("Connected Device: $connectedDevice"),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () => _toggleFavorite(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.grey),
                                      onPressed: () => _deleteDevice(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({bool filled = false}) {
    const cardSize = Size(120, 100);

    return filled
        ? Container(
            width: cardSize.width,
            height: cardSize.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          )
        : DottedBorder(
            color: Colors.grey.shade600,
            strokeWidth: 1.5,
            dashPattern: [6, 3],
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            padding: EdgeInsets.zero,
            child: Container(
              width: cardSize.width,
              height: cardSize.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
            ),
          );
  }
}
