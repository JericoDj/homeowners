
import 'package:flutter/material.dart';
import 'package:homeowners/screens/user_selection_page.dart';

import 'group_chat.dart';

class ChatSelectionPage extends StatelessWidget {
  const ChatSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Selection'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Select User to Chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSelectionPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Group Chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupChatPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}