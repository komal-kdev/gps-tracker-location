import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  final List<String> _deviceTypes = [
    'Bus', 'Car', 'Auto', 'Scooty', 'Lorry', 'Bike', 'Truck'
  ];
  String? _selectedDeviceType;

  final Map<String, String> _deviceIcons = {
    'Car': 'directions_car',
    'Bike': 'motorcycle',
    'Bus': 'directions_bus',
    'Auto': 'electric_rickshaw',
    'Scooty': 'electric_scooter',
    'Lorry': 'local_shipping',
    'Truck': 'local_shipping',
  };

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/devices_data.json');
  }

  Future<File> get _signupFile async {
    final path = await _localPath;
    return File('$path/signup_data.json');
  }

  Future<void> _saveDevice() async {
    if (_formKey.currentState!.validate()) {
      final file = await _localFile;
      final signupFile = await _signupFile;
      final doreg = DateTime.now().toString();
      final icon = _deviceIcons[_selectedDeviceType] ?? 'device_unknown';

      final newDevice = {
        'deviceName': _deviceNameController.text.trim(),
        'nickName': _nickNameController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'connectedDevice': _selectedDeviceType ?? '',
        'isFavorite': false,
        'doreg': doreg,
        'icon': icon,
      };

      // Save to devices_data.json
      List<dynamic> devices = [];
      final existingContent = await file.readAsString().catchError((_) => '');
      if (existingContent.isNotEmpty) {
        try {
          devices = jsonDecode(existingContent);
        } catch (_) {}
      }
      devices.add(newDevice);
      await file.writeAsString(jsonEncode(devices), flush: true);

      // Also update latest user's device list in signup_data.json
      List<dynamic> users = [];
      final signupContent = await signupFile.readAsString().catchError((_) => '');
      if (signupContent.isNotEmpty) {
        try {
          users = jsonDecode(signupContent);
        } catch (_) {}
      }
      if (users.isNotEmpty) {
        users.last['devices'] = List<Map<String, dynamic>>.from(users.last['devices'] ?? []);
        users.last['devices'].add(newDevice);
        await signupFile.writeAsString(jsonEncode(users), flush: true);
      }

      // Reset form
      setState(() {
        _deviceNameController.clear();
        _nickNameController.clear();
        _serialNumberController.clear();
        _selectedDeviceType = null;
      });
if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Device')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _deviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter device name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nickNameController,
                decoration: const InputDecoration(
                  labelText: 'Nick Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter nick name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter serial number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Connected Device',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDeviceType,
                items: _deviceTypes.map((device) {
                  return DropdownMenuItem<String>(
                    value: device,
                    child: Text(device),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceType = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Select connected device'
                    : null,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDevice,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _deviceNameController.clear();
                        _nickNameController.clear();
                        _serialNumberController.clear();
                        setState(() {
                          _selectedDeviceType = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
