import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:homeowners/screens/landing_page.dart';
import '../screens/authentication/tenants_loginscreen.dart';
import '../screens/user_navigation.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  /// Determines the initial screen based on authentication status
  Widget getInitialScreen() {
    String? userId = _storage.read("user");

    if (userId != null) {
      return UserNavigation(); // If logged in, go to Home
    } else {
      return LandingPage(
      ); // If not logged in, go to Login
    }
  }

  /// Sign in method
  Future<User?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _storage.write("user", userCredential.user!.uid);
      Get.offAll(() => UserNavigation()); // Redirect to UserNavigation after login

      return userCredential.user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      return null;
    }
  }

  /// Sign up method
  /// Sign up method
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String idUrl, // Add this parameter
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore, including ID URL
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'idUrl': idUrl, // Store uploaded ID URL in Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user session locally
      _storage.write("user", userCredential.user!.uid);

      // Redirect to User Navigation after sign-up
      Get.offAll(() => UserNavigation());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign-up successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  /// Password reset method
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Logout function
  Future<void> signOut() async {
    await _auth.signOut();
    _storage.remove("user");
    Get.offAll(() => LandingPage()); // Redirect to Landing Page after logout
  }
}
