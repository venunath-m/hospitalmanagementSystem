import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Configuration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Profile'),
            onTap: () {
              // TODO: Navigate to User Profile Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // TODO: Navigate to Change Password Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              // TODO: Show app info
            },
          ),
          // Add more config options here
        ],
      ),
    );
  }
}
