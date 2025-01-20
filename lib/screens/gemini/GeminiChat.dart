import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart';

class GeminiChatScreen extends StatefulWidget {
  @override
  _GeminiChatScreenState createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
    id: "0",
    firstName: "User",
    profileImage: "assets/images/user_profile.png", // User's profile picture
  );

  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage: "assets/images/logo/Gemini_Logo.png", // Gemini's profile picture
  );

  final Gemini gemini = Gemini.instance; // Initialize Gemini AI

  void _sendMessage(ChatMessage chatMessage) {
    try {
      setState(() {
        messages = [chatMessage, ...messages]; // Prepend user message
      });

      // Fetch AI response using streaming
      _getGeminiResponse(chatMessage.text);

    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> _getGeminiResponse(String userInput) async {
    try {
      // Get the current UTC time
      DateTime now = DateTime.now().toUtc();
      String currentDate = DateFormat('MMMM dd, yyyy').format(now);
      String currentTimeUTC = DateFormat('HH:mm:ss').format(now);

      ChatMessage botReply = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "", // Initially empty, will be updated dynamically
      );

      setState(() {
        messages = [botReply, ...messages]; // Add an empty AI response first
      });

      // Build conversation history for context
      List<ChatMessage> messageList = messages.skip(1).toList();
      String conversationHistory = messageList.reversed
          .map((msg) => "${msg.user.firstName}: ${msg.text}")
          .join("\n");

      // Define Gemini AI's identity and provide real-time date & time
      String systemPrompt = """
      You are Gemini, an AI assistant created by Google.
      The current UTC time is $currentTimeUTC, and the date is $currentDate.
      If the user asks for the time in a specific country, convert it based on its time zone offset from UTC.
      Always provide accurate and reliable responses.
      
      Conversation History:
      $conversationHistory
      """;

      // Combine system prompt with user input
      String modifiedUserInput = "$systemPrompt\n\nUser: $userInput";

      // Store streamed response dynamically
      StringBuffer aiResponseBuffer = StringBuffer();
      bool isFirstChunk = true;

      gemini.streamGenerateContent(modifiedUserInput).listen((event) {
        String newText = event.output?.trim() ?? ""; // Trim leading/trailing spaces

        // Ensure proper spacing before appending
        if (aiResponseBuffer.isNotEmpty && !isFirstChunk) {
          aiResponseBuffer.write(" "); // Add a space if buffer is not empty
        }

        aiResponseBuffer.write(newText);
        isFirstChunk = false; // After first chunk, set this to false

        setState(() {
          messages[0] = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: aiResponseBuffer.toString(),
          );
        });
      });

    } catch (e) {
      print("Error fetching AI response: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Match with the theme

        body: Column(
          children: [
            const SizedBox(height: 20),
            // Gemini Logo & Title
            Column(
              children: [
                Image.asset(
                  "assets/images/logo/Gemini_Logo.png",
                  height: 80, // Adjust logo size
                ),
                const SizedBox(height: 10),
                const Text(
                  "Gemini Chat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
              ],
            ),
            Expanded(
              child: DashChat(
                currentUser: currentUser,
                onSend: _sendMessage,
                messages: messages,
                inputOptions: InputOptions(
                  sendButtonBuilder: (void Function() send) => IconButton(
                    icon: Icon(Icons.send, color: Colors.indigo), // Indigo send button
                    onPressed: send, // This ensures the send button functions correctly
                  ),
                ),
                messageOptions: MessageOptions(
                  currentUserContainerColor: Colors.indigo, // Indigo chat bubble for User
                  currentUserTextColor: Colors.white, // White text in User messages
                  messagePadding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
