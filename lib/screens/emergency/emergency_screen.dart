import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/announcementUploading.dart';

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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📢 Announcement & Uploading Card
              AnnouncementUploadingCard(
                landlordName: 'Bascara Apartment',
                landlordPhone: '+63 917 700 0710',
                showUploadSection: false, // No Upload Documents in Emergency
                showLandlordContact: true, // Show Landlord Contact
              ),

              const SizedBox(height: 20),

              // 🚨 Emergency Contacts Section
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    label: "Fire",
                    icon: Icons.local_fire_department,
                    color: Colors.red,
                    phoneNumber: "09771981900",
                  ),
                  _buildQuickAction(
                    label: "Ambulance",
                    icon: Icons.local_hospital,
                    color: Colors.green,
                    phoneNumber: "09273913784",
                  ),
                  _buildQuickAction(
                    label: "Police",
                    icon: Icons.local_police,
                    color: Colors.indigo,
                    phoneNumber: "09985987506",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📞 Concerns and Repair & Maintenance Contact in One Card
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Emergency Contacts:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildEmergencyListTile(
                      title: "For Concerns",
                      phoneNumber: "0917 700 0710",
                    ),
                    _buildEmergencyListTile(
                      title: "For Repair & Maintenance",
                      phoneNumber: "0951 392 3728",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build an emergency contact ListTile with a call button
  Widget _buildEmergencyListTile({required String title, required String phoneNumber}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(phoneNumber),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.indigo),
        onPressed: () => _callNumber(phoneNumber),
      ),
    );
  }

  // Function to build quick action buttons
  Widget _buildQuickAction({required String label, required IconData icon, required Color color, required String phoneNumber}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _callNumber(phoneNumber),
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
