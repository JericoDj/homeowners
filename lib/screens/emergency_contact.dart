import 'package:flutter/material.dart';

class EmergencyContactPage extends StatelessWidget {
  const EmergencyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.red),
            title: const Text('Police'),
            subtitle: const Text('Dial 911 for emergencies'),
            onTap: () {
              // Add phone dialer functionality here
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital, color: Colors.red),
            title: const Text('Ambulance'),
            subtitle: const Text('Dial 112 for medical emergencies'),
            onTap: () {
              // Add phone dialer functionality here
            },
          ),
          ListTile(
            leading: const Icon(Icons.fire_truck, color: Colors.red),
            title: const Text('Fire Department'),
            subtitle: const Text('Dial 101 for fire emergencies'),
            onTap: () {
              // Add phone dialer functionality here
            },
          ),
        ],
      ),
    );
  }
}
