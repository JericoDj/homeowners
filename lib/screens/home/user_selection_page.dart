import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'one_2_one_chat_page.dart';

class UserSelectionPage extends StatelessWidget {
  UserSelectionPage({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['fullName'] ?? 'Unknown User'), // Ensure full name is displayed
                subtitle: Text(user['email']), // Show email as a subtitle
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OneToOneChatPage(
                        receiverEmail: user['email'],
                        receiverName: user['fullName'] ?? 'Unknown User', // Pass the receiverName
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
