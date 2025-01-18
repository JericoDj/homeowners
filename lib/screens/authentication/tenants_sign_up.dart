import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:homeowners/screens/authentication/tenants_loginscreen.dart';

import '../../repository/authentication_repository.dart';

class TenantsSignUpScreen extends StatefulWidget {
  const TenantsSignUpScreen({super.key});

  @override
  _TenantsSignUpScreenState createState() => _TenantsSignUpScreenState();
}

class _TenantsSignUpScreenState extends State<TenantsSignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final AuthenticationRepository _authRepo = AuthenticationRepository();

  File? _selectedFile;
  String? _uploadedIdUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _isUploading = true;
      });

      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      String filePath = 'user_ids/$userId/${result.files.single.name}';

      try {
        Reference storageRef = FirebaseStorage.instance.ref(filePath);
        UploadTask uploadTask = storageRef.putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadedIdUrl = downloadUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID uploaded successfully!')),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'New Tenants? Sign up here.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter password...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Full Name', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter full name...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Upload Valid ID Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Upload Valid ID', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 5),
                      _isUploading
                          ? Center(child: CircularProgressIndicator())
                          : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickAndUploadFile,
                              icon: Icon(Icons.upload_file, color: Colors.white), // Add icon
                              label: Text("Choose File"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo, // Match theme color
                                foregroundColor: Colors.white, // Text color
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // Rounded edges
                                ),
                                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (_uploadedIdUrl != null)
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                            ),
                        ],
                      ),


                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () async {
                            if (_uploadedIdUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please upload a valid ID')),
                              );
                              return;
                            }

                            await _authRepo.signUp(
                              email: _emailController.text,
                              password: _passwordController.text,
                              fullName: _fullNameController.text,
                              idUrl: _uploadedIdUrl ?? "", // Pass Uploaded ID URL
                              context: context,
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => LoginScreen());
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
