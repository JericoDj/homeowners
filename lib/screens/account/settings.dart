import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:slidable_button/slidable_button.dart';
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
              AnnouncementUploadingCard(
                landlordName: 'Bascara Apartment',
                landlordPhone: '+63 912 345 6789',
                showUploadSection: true,
                showLandlordContact: false,
              ),
              const SizedBox(height: 20),
              const PaymentMethodsCard(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.redAccent),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    GetStorage().erase();
                    Get.offAll(() => LandingPage());
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onPressed: () => _showDeleteConfirmation(context),
                  child: const Text(
                    'Delete My Account',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _askForPassword(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Re-authenticate"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter your password to continue."),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

    Future<void> _reauthenticateAndDeleteAccount(BuildContext context) async {
      try {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final providerData = user.providerData.first;
          AuthCredential credential;

          if (providerData.providerId == 'password') {
            String email = user.email!;
            String? password = await _askForPassword(context);
            if (password == null) return;
            credential = EmailAuthProvider.credential(email: email, password: password);
          } else {
            GoogleAuthProvider googleProvider = GoogleAuthProvider();
            UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(googleProvider);
            credential = userCredential.credential!;
          }

          await user.reauthenticateWithCredential(credential);
          // Delete user data from Firestore
          await _firestore.collection('users').doc(user.uid).delete();

          await user.delete();

          GetStorage().erase();
          Get.offAll(() => LandingPage());

          Get.snackbar(
            "Account Deleted",
            "Your account has been permanently deleted.",
            backgroundColor: Colors.indigo,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to delete account: $e",
          backgroundColor: Colors.indigo,
          colorText: Colors.white,
        );
      }
    }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Slide to confirm account deletion."),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Slide to Confirm",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                HorizontalSlidableButton(
                  width: MediaQuery.of(context).size.width * 0.8,
                  buttonWidth: 60.0,
                  color: Colors.transparent,
                  buttonColor: Colors.indigo,
                  borderRadius: BorderRadius.circular(50),
                  dismissible: false,
                  label: const Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (position) {
                    if (position == SlidableButtonPosition.end) {
                      Navigator.pop(context);
                      _reauthenticateAndDeleteAccount(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
