import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDummyScreen extends StatefulWidget {
  const SecureStorageDummyScreen({super.key});

  @override
  State<SecureStorageDummyScreen> createState() => _SecureStorageDummyScreenState();
}

class _SecureStorageDummyScreenState extends State<SecureStorageDummyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Map<String, String>> _entries = [];
  bool _isDataVisible = false;
  int? _editIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    final newEntry = {
      'name': _nameController.text,
      'info': _infoController.text,
    };

    _entries.add(newEntry);
    await _secureStorage.write(key: 'entries', value: jsonEncode(_entries));

    _nameController.clear();
    _infoController.clear();
    _editIndex = null;

    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Saved')));
  }

  Future<void> _updateEntry() async {
    if (_editIndex != null) {
      _entries[_editIndex!] = {
        'name': _nameController.text,
        'info': _infoController.text,
      };
      await _secureStorage.write(key: 'entries', value: jsonEncode(_entries));

      _nameController.clear();
      _infoController.clear();
      _editIndex = null;

      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry Updated')));
    }
  }

  Future<void> _loadData() async {
    final rawData = await _secureStorage.read(key: 'entries');
    if (!mounted) return;
    if (rawData != null) {
      final List decoded = jsonDecode(rawData);
      setState(() {
        _entries = List<Map<String, String>>.from(decoded);
      });
    } else {
      setState(() {
        _entries = [];
      });
    }
  }

  Future<void> _deleteAll() async {
    await _secureStorage.delete(key: 'entries');
    await _loadData();
  }

  void _showData() {
    setState(() {
      _isDataVisible = true;
    });
  }

  void _hideData() {
    setState(() {
      _isDataVisible = false;
    });
  }

  void _loadEntryIntoFields(int index) {
    setState(() {
      _nameController.text = _entries[index]['name'] ?? '';
      _infoController.text = _entries[index]['info'] ?? '';
      _editIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Storage CRUD')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(
                labelText: 'Info',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('load'),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _updateEntry,
                  child: const Text('Update'),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _deleteAll,
                  child: const Text('Delete All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showData,
                  child: const Text('Show Data'),
                ),
                ElevatedButton(
                  onPressed: _hideData,
                  child: const Text('Hide Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isDataVisible)
              Expanded(
                child: ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return GestureDetector(
                      onTap: () => _loadEntryIntoFields(index),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${entry['name']}'),
                              Text('Info: ${entry['info']}'),
                            ],
                          ),
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
}
