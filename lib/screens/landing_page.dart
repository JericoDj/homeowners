import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:homeowners/screens/tenants_loginscreen.dart';
import 'package:homeowners/screens/tenants_sign_up.dart';


import 'chat_selection.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Login with Email
  Future<void> _loginWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      print("✅ Logged in as: \${user?.displayName ?? 'No display name set'}");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatSelectionPage()),
      );
    } catch (e) {
      print("❌ Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  /// Login with Google
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      print("✅ Google Sign-In successful! User: \${user?.displayName ?? 'No display name set'}");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatSelectionPage()),
      );
    } catch (e) {
      print("❌ Google login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              Text(
                'BASCARA APT.',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Welcome to Bascara Apartment!",style: TextStyle(color: Colors.white,fontSize: 12),),
                ),
              ),
              Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    Center(child: Image.asset("assets/images/logo/Logo_new.png", height: 150)),

                    Positioned(
                      left:180,
                      top: 50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("We bring you comfortable home",style: TextStyle(fontSize: 10),),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("New Tenant? Create your account to communicate Us.",style: TextStyle(color: Colors.white,fontSize: 12),),
                ),
              ),

              const SizedBox(height: 50),


              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.white,
                  border: Border.all(color: Colors.blueAccent),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Removes the button color
                    shadowColor: Colors.transparent, // Removes the button shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Matches the container
                    ),
                  ),
                  onPressed: () {
                    Get.to(()=> TenantsSignUpScreen());

                  },
                  child: Text('SIGN UP',style: TextStyle(color: Colors.blueAccent),),
                ),
              ),
              SizedBox(height: 10,),
              TextButton.icon(
                onPressed: () {
                  Get.to(()=> LoginScreen());
                },
                icon: const Icon(Icons.house,color: Colors.black,),
                label: const Text('TENANTS LOG IN HERE',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,letterSpacing: 1.5),),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
