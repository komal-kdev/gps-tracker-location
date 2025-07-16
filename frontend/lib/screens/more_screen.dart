import 'package:flutter/material.dart';
import 'package:gps_tracker/screens/live_map_screen.dart';
import 'package:gps_tracker/screens/dummy_map_screen.dart';
import 'package:gps_tracker/screens/geofence_screen.dart';
import 'package:gps_tracker/screens/history_screen.dart';
import 'package:gps_tracker/screens/map_screen.dart';
import 'package:gps_tracker/screens/secure_storage_dummy_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _optionTileWithDivider(
            icon: Icons.location_on,
            color: Colors.orange,
            title: 'Geofence',
          ),
          _optionTileWithDivider(
            icon: Icons.monitor_heart,
            color: Colors.green,
            title: 'Share Monitoring',
          ),
          _optionTileWithDivider(
            icon: Icons.person,
            color: Colors.purple,
            title: 'Drivers',
          ),
          _optionTileWithDivider(
            icon: Icons.message,
            color: Colors.blue,
            title: 'Messages',
          ),
          _optionTileWithDivider(
            icon: Icons.language,
            color: Colors.orangeAccent,
            title: 'Language',
          ),
          _optionTileWithDivider(
            icon: Icons.headphones,
            color: Colors.deepPurple,
            title: 'Help & Support',
          ),
          _optionTileWithDivider(
            icon: Icons.logout,
            color: Colors.red,
            title: 'Log Out',
          ),

          // Below are your functional ListTiles
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Maps'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveMapScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.abc_outlined),
            title: const Text('Dummy screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SecureStorageDummyScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Dummy Map screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DummyMapScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text(' live Map screen'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
          
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LiveTrackingScreen(),
  ),
);




            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('History'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
          ),
           const Divider(),

          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Dummy Geo Fencing'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GeofenceScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

 
  Widget _optionTileWithDivider({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Column(
      children: [
        _OptionTile(icon: icon, color: color, title: title),
        const Divider(height: 0),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _OptionTile({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha((0.2 * 255).toInt()),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Optional: Add navigation or dialog
      },
    );
  }
}
