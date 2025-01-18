import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OneToOneChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  OneToOneChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverName,
  });

  /// Generates a consistent chat ID based on both user emails
  String _getChatId(String user1, String user2) {
    List<String> emails = [user1, user2];
    emails.sort(); // Ensure the same order every time
    return emails.join("_");
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final String senderEmail = FirebaseAuth.instance.currentUser?.email ?? "";
      final String chatId = _getChatId(senderEmail, receiverEmail);
      final String messageText = _messageController.text;

      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Save the message inside the messages subcollection
      await chatRef.collection('messages').add({
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': senderEmail,
        'receiver': receiverEmail,
      });

      // Update the parent chat document with the latest message
      await chatRef.set({
        'lastMessage': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'users': [senderEmail, receiverEmail],
      }, SetOptions(merge: true));

      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    final String chatId = _getChatId(currentUserEmail, receiverEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message['sender'] == currentUserEmail;

                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isSender ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
