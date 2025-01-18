import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeowners/screens/landing_page.dart';
import '../../widgets/announcementUploading.dart';
import '../../widgets/payment_methods_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📢 Announcement Uploading Card
              AnnouncementUploadingCard(
                landlordName: 'Bascara Apartment',
                landlordPhone: '+63 912 345 6789',
                showUploadSection: true,
                showLandlordContact: false,
              ),

              const SizedBox(height: 20),

              // 💰 Payment Methods Card (Imported)
              const PaymentMethodsCard(),

              const SizedBox(height: 20),

              // 🔴 Logout Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(() => LandingPage());
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
