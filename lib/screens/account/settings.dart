import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeowners/screens/landing_page.dart';

import '../widgets/announcementUploading.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              AnnouncementUploadingCard(
                landlordName: 'Bascara Apartment',
                landlordPhone: '+63 912 345 6789',
                showUploadSection: true, // No Upload Documents in Account
                showLandlordContact: false, // Show Landlord Contact
              ),



              const SizedBox(height: 20),

              // Payment Methods Section
              _buildPaymentMethodsCard(),

              const SizedBox(height: 20),

              // Logout Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
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


  /// Payment Methods Card
  Widget _buildPaymentMethodsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Billing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Month of: January 2024"),
            Text("Due Date: 15th January 2024"),
            Text("Amount Due: \$150"),
            Text("Remaining Balance: \$50"),

            Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Methods',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // GCash / PayMaya
                      _buildPaymentItem(
                          'GCash / PayMaya', '0917 700 0710', 'Bascara Apartment'),

                      const SizedBox(height: 8),

                      // Over-the-Counter
                      _buildPaymentItem(
                          'Over-the-Counter',
                          '0917 700 0710', 'M Lhuillier / Palawan / Cebuana', 'Bascara Apartment'),

                      const SizedBox(height: 8),

                      // Bank Transfers
                      _buildPaymentItem(
                          'BDO', '5210 6988 8182 2136', 'Bascara Apartment'),
                      _buildPaymentItem(
                          'China Bank', '5210 6988 8182 2136', 'Bascara Apartment'),
                      _buildPaymentItem(
                          'BPI', '5210 6988 8182 2136', 'Bascara Apartment'),
                      _buildPaymentItem(
                          'Land Bank', '5210 6988 8182 2136', 'Bascara Apartment'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Widget for Payment Methods
  Widget _buildPaymentItem(String title, String account, String? holder,
      [String? extra]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        Text(
          account,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (extra != null) Text(extra, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        Text(
          holder ?? '', // Ensures holder is not null
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        const Divider(),
      ],
    );
  }
}