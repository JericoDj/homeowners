import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/announcementUploading.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // Function to dial a phone number
  void _callNumber(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📢 Announcement & Uploading Card
            AnnouncementUploadingCard(
              landlordName: 'Bascara Apartment',
              landlordPhone: '+63 912 345 6789',
              showUploadSection: false, // No Upload Documents in Emergency
              showLandlordContact: true, // Show Landlord Contact
            ),

            const SizedBox(height: 20),

            // 🚨 Emergency Contacts Section
            const Text(
              "Emergency Numbers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildEmergencyCard("Fire Department", "911"),
            _buildEmergencyCard("Police Station", "911"),
            _buildEmergencyCard("Hospital Emergency", "+1 800 123 456"),
            _buildEmergencyCard("Gas Leak Hotline", "+1 800 654 321"),

            const SizedBox(height: 20),

            // ⚡ Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction("Fire", Icons.local_fire_department, Colors.red, () => _callNumber("911")),
                _buildQuickAction("Ambulance", Icons.local_hospital, Colors.green, () => _callNumber("+1800123456")),
                _buildQuickAction("Police", Icons.local_police, Colors.blue, () => _callNumber("911")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build an emergency contact card
  Widget _buildEmergencyCard(String title, String phoneNumber) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.redAccent),
          onPressed: () => _callNumber(phoneNumber),
        ),
      ),
    );
  }

  // Function to build quick action buttons
  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
