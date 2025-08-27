import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared/user_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class Chatbot {
  static TextEditingController inputController = TextEditingController();
  // Store the chat history in a list
  static List<ChatMessage> chatHistory = [];

  // Create a notifier to update the chat history
  static ValueNotifier<List<ChatMessage>> chatHistoryNotifier =
      ValueNotifier<List<ChatMessage>>([]);

  // Initialize chat message
  static void initializeChat() {
    if (chatHistory.isEmpty) {
      chatHistory.add(
        ChatMessage(text: "Hello! How can I help you today?", isUser: false),
      );
      chatHistoryNotifier.value = List.from(chatHistory);
    }
  }

  // Function to chat with the AI
  static Future<String> chatWithAI(String url, String message) async {
    try {
      var chatbotResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserProvider.userJwtToken}',
        },
        body: jsonEncode({'message': message}),
      );

      if (chatbotResponse.statusCode == 200) {
        final responseBody = jsonDecode(chatbotResponse.body);
        return responseBody['reply'];
      } else {
        print("Chatbot error: ${chatbotResponse.statusCode}");
        return "Error: ${chatbotResponse.statusCode}";
      }
    } catch (e) {
      print("Error: $e");
      return "Error: $e";
    }
  }

  // Function to build the chatbot page
  static Container chatbotPage(BuildContext context) {
    // Initialize chat when page is built
    initializeChat();

    return Container(
      color: Shared.bgColor,
      child: Column(
        children: [
          // Header
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 60,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Chatbot',
                  style: Shared.fontStyle(32, FontWeight.w500, Shared.orange),
                ),
              ),
            ),
          ),

          // Chat messages area
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: chatHistoryNotifier,
              builder: (context, chatHistory, child) {
                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = chatHistory[index];
                    return Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Shared.orange
                              : Shared.lightGray2,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Text(
                          message.text,
                          style: Shared.fontStyle(
                            24,
                            FontWeight.w400,
                            message.isUser ? Shared.bgColor : Shared.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Shared.inputContainer(
              double.maxFinite,
              'Ask me anything',
              inputController,
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  // Add user message to chat history
                  chatHistory.add(ChatMessage(text: value, isUser: true));
                  chatHistoryNotifier.value = List.from(chatHistory);

                  // Clear input
                  inputController.clear();

                  // Show loading message
                  chatHistory.add(
                    ChatMessage(text: "Typing...", isUser: false),
                  );
                  chatHistoryNotifier.value = List.from(chatHistory);

                  // Get AI response
                  final response = await chatWithAI(
                    AppConfig.chatbotUrl,
                    value,
                  );

                  // Remove loading message and add actual response
                  chatHistory.removeLast();
                  chatHistory.add(ChatMessage(text: response, isUser: false));
                  chatHistoryNotifier.value = List.from(chatHistory);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
