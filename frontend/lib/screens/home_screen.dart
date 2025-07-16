import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _favoriteDevices = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteDevices();
  }

  Future<void> _loadFavoriteDevices() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/devices_data.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> devices = jsonDecode(content);
        setState(() {
          _favoriteDevices =
              devices.where((device) => device['isFavorite'] == true).toList();
        });
      }
    } catch (e) {
      debugPrint('Error reading devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 32,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            iconSize: 30,
            onPressed: () {},
          ),
          const SizedBox(width: 7),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color.fromRGBO(29, 19, 184, 1),
            child: Text(
              'K',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Text(
                      "See All (6)",
                      style: TextStyle(
                        color: Color(0xFF123456),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF123456),
                      size: 25,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 260),
            Row(
              children: const [
                Text(
                  "Favourites",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "Edit",
                  style: TextStyle(
                    color: Color(0xFF123456),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.7,
                  children: List.generate(7, (index) {
                    if (index < _favoriteDevices.length) {
                      final device = _favoriteDevices[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(245, 245, 245, 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device['deviceName'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text('Nickname: ${device['nickName'] ?? ''}'),
                            Text('Serial: ${device['serialNumber'] ?? ''}'),
                            Text("Connected Device: ${device['connectedDevice']}"),


                          ],
                        ),
                      );
                    } else {
                      return DottedBorder(
                        color: Colors.grey.shade400,
                        strokeWidth: 1,
                        dashPattern: [6, 3],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        child: Container(),
                      );
                    }
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
