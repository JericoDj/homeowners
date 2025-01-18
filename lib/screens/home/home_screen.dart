import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeowners/screens/settings.dart';

import '../widgets/announcementUploading.dart';
import 'one_2_one_chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            SizedBox(height: 20,),
            // Announcements & Emergency Contact Section
            AnnouncementUploadingCard(
              landlordName: 'Bascara Apartment',
              landlordPhone: '+63 912 345 6789',
              showUploadSection: true, // Show Upload Documents
              showLandlordContact: false, // Show Landlord Contact
            ),
            SizedBox(height: 20,),
      
            // Search People Bar
            Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search people...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
      
            // Chat List Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text('User \$index'),
                      subtitle: Text('Last message from User \$index'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.to(() => OneToOneChatPage(receiverEmail: 'user\$index@example.com'));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
