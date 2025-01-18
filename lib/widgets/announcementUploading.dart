import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class AnnouncementUploadingCard extends StatefulWidget {
  final String landlordName;
  final String landlordPhone;
  final bool showUploadSection;
  final bool showLandlordContact;

  const AnnouncementUploadingCard({
    super.key,
    required this.landlordName,
    required this.landlordPhone,
    this.showUploadSection = false,
    this.showLandlordContact = true,
  });

  @override
  _AnnouncementUploadingCardState createState() => _AnnouncementUploadingCardState();
}

class _AnnouncementUploadingCardState extends State<AnnouncementUploadingCard> {
  String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool _isUploading = false; // Track upload status

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      DateTime now = DateTime.now();
      int cutoffDay = 15;

      // Determine storage folder based on the 15th-day cutoff
      String monthFolder = now.day <= cutoffDay
          ? DateFormat('MMMM yyyy').format(now)
          : DateFormat('MMMM yyyy').format(DateTime(now.year, now.month + 1, 1));

      String fileName = result.files.single.name;
      String filePath = 'uploads/$currentUserUid/$monthFolder/$fileName';

      try {
        setState(() {
          _isUploading = true;
        });

        // Upload file to Firebase Storage with progress tracking
        Reference storageRef = FirebaseStorage.instance.ref(filePath);
        UploadTask uploadTask = storageRef.putFile(file);

        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print("Upload progress: $progress%");
        });

        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save file metadata in Firestore
        await FirebaseFirestore.instance
            .collection('uploads')
            .doc(currentUserUid)
            .collection(monthFolder)
            .add({
          'fileName': fileName,
          'fileUrl': downloadUrl,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
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

  Future<void> _viewFiles() async {
    DateTime now = DateTime.now();
    int cutoffDay = 15;
    String monthFolder = now.day <= cutoffDay
        ? DateFormat('MMMM yyyy').format(now)
        : DateFormat('MMMM yyyy').format(DateTime(now.year, now.month + 1, 1));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('uploads')
        .doc(currentUserUid)
        .collection(monthFolder)
        .orderBy('uploadedAt', descending: true)
        .get();

    List<DocumentSnapshot> files = snapshot.docs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Uploaded Files for $monthFolder"),
        content: files.isEmpty
            ? Text("No files uploaded yet.")
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: files.map((file) {
            String fileName = file['fileName'];
            String fileUrl = file['fileUrl'];

            return ListTile(
              title: Text(fileName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                    onPressed: () async {
                      await launchUrl(Uri.parse(fileUrl)); // Open file
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('uploads')
                          .doc(currentUserUid)
                          .collection(monthFolder)
                          .doc(file.id)
                          .delete();

                      Navigator.pop(context);
                      _viewFiles(); // Refresh list
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📢 Announcement Section
              const Text(
                'Hello, Tenant!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Important Announcements:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Please settle your monthly dues before the 15th.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),

              // 📞 Landlord Contact (Only if enabled)
              if (widget.showLandlordContact) ...[
                const Text(
                  'Landlord Contact:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.landlordName} - ${widget.landlordPhone}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () async {
                    final Uri url = Uri.parse("tel:${widget.landlordPhone}");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      debugPrint("Could not launch ${widget.landlordPhone}");
                    }
                  },
                  child: const Text('Call Landlord', style: TextStyle(color: Colors.white)),
                ),
              ],

              // 📤 Upload Section (Only if enabled)
              if (widget.showUploadSection) ...[
                const Text(
                  'Upload Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _isUploading
                    ? Center(child: CircularProgressIndicator()) // Show loading indicator
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      onPressed: _uploadFile,
                      child: const Text('Upload File', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      onPressed: _viewFiles,
                      child: const Text('View Uploaded Files', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
