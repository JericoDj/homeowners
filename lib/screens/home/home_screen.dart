import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../widgets/announcementUploading.dart';
import 'one_2_one_chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  Map<String, String> _userNamesCache = {}; // Caches user names
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? ""; // Store logged-in user

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch and cache user names to reduce Firestore reads
  Future<String> _getUserName(String email) async {
    if (_userNamesCache.containsKey(email)) {
      return _userNamesCache[email]!; // Return cached name
    }

    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      String fullName = userDoc.docs.first['fullName'] ?? email;
      _userNamesCache[email] = fullName; // Cache it
      return fullName;
    }
    return email;
  }

  void _showUserModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {}); // Update UI when search changes
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator(color: Colors.black));
                          }

                          var users = snapshot.data!.docs.where((user) {
                            String email = user['email'] ?? '';

                            // **Remove current user from list**
                            if (email == currentUserEmail) return false;

                            // Apply search filter
                            String name = user['fullName']?.toLowerCase() ?? '';
                            return name.contains(_searchController.text.toLowerCase());
                          }).toList();

                          return users.isEmpty
                              ? Center(child: Text("No users found"))
                              : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              var user = users[index];
                              String name = user['fullName'] ?? 'Unknown';
                              String email = user['email'] ?? 'No Email';

                              _userNamesCache[email] = name; // Pre-cache user names

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(name),
                                subtitle: Text(email),
                                onTap: () {
                                  Navigator.pop(context);
                                  Get.to(() => OneToOneChatPage(
                                    receiverEmail: email,
                                    receiverName: name,
                                  ));
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnnouncementUploadingCard(
                landlordName: 'Bascara Apartment',
                landlordPhone: '+63 912 345 6789',
                showUploadSection: true,
                showLandlordContact: false,
              ),
              Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showUserModal(context);
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Chat with other Tenants',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('users', arrayContains: currentUserEmail)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: Colors.black));
                    }

                    var chats = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        var chat = chats[index];
                        List<dynamic> users = chat['users'];

                        // **Remove current user from chat list**
                        String? otherUserEmail = users.firstWhere(
                              (user) => user != currentUserEmail,
                          orElse: () => null,
                        );

                        // Skip if no other user found (e.g., error in Firestore)
                        if (otherUserEmail == null) return SizedBox.shrink();

                        var lastMessage = chat["lastMessage"] ?? "No messages yet";

                        // Use cached name if available
                        if (_userNamesCache.containsKey(otherUserEmail)) {
                          return _buildChatTile(otherUserEmail, _userNamesCache[otherUserEmail]!, lastMessage);
                        }

                        // Otherwise, fetch and cache it
                        return FutureBuilder<String>(
                          future: _getUserName(otherUserEmail),
                          builder: (context, nameSnapshot) {
                            if (!nameSnapshot.hasData) {
                              return ListTile(
                                title: Text("Loading..."),
                                subtitle: Text("Fetching user info..."),
                              );
                            }

                            _userNamesCache[otherUserEmail] = nameSnapshot.data!; // Cache the name
                            return _buildChatTile(otherUserEmail, nameSnapshot.data!, lastMessage);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(String email, String name, String lastMessage) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text(lastMessage),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Get.to(() => OneToOneChatPage(
          receiverEmail: email,
          receiverName: name,
        ));
      },
    );
  }
}
