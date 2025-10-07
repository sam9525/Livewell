import 'package:flutter/material.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import '../shared/shared.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared/user_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class Chatbot {
  static final TextEditingController inputController = TextEditingController();
  // Store the chat history in a list
  static final List<ChatMessage> chatHistory = [];

  // Create a notifier to update the chat history
  static final ValueNotifier<List<ChatMessage>> chatHistoryNotifier =
      ValueNotifier<List<ChatMessage>>([]);

  // A notifier for if speech is listening
  static final ValueNotifier<bool> _isListeningNotifier = ValueNotifier<bool>(
    false,
  );

  static final FlutterTts flutterTts = FlutterTts();
  static final stt.SpeechToText _speechToText = stt.SpeechToText();
  static bool _speechEnabled = false;

  // Prevent multiple initializations
  static bool _isChatInitialized = false;
  static bool _isTTSInitialized = false;
  static bool _isSpeechInitialized = false;

  // Initialize chat message
  static void initializeChat() {
    if (chatHistory.isEmpty && !_isChatInitialized) {
      chatHistory.add(
        ChatMessage(text: "Hello! How can I help you today?", isUser: false),
      );
      chatHistoryNotifier.value = List.from(chatHistory);
    }
    _isChatInitialized = true;
  }

  static Future<void> initializeTTS() async {
    if (!_isTTSInitialized) {
      await flutterTts.setLanguage("en-AU");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      _isTTSInitialized = true;
    }
  }

  static Future<void> initializeSpeech() async {
    if (!_isSpeechInitialized) {
      try {
        _speechEnabled = await _speechToText.initialize(
          onError: (error) {
            debugPrint("Speech recognition error: ${error.errorMsg}");
            _isListeningNotifier.value = false;
          },
          onStatus: (status) {
            debugPrint("Speech recognition status: $status");
            if (status == 'done' || status == 'notListening') {
              _isListeningNotifier.value = false;
            }
          },
        );
        debugPrint("Speech recognition initialized: $_speechEnabled");
        _isSpeechInitialized = true;
      } catch (e) {
        debugPrint("Error initializing speech recognition: $e");
        _speechEnabled = false;
        _isSpeechInitialized = true;
      }
    }
  }

  // Function to chat with the AI
  static Future<String> chatWithAI(String url, String message) async {
    try {
      // Get the jwt token from the shared preferences
      final jwtToken =
          UserProvider.userJwtToken ??
          SharedPreferencesProvider.backgroundPrefs?.getString('jwt_token') ??
          '';

      var chatbotResponse = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(Duration(seconds: 30));

      if (chatbotResponse.statusCode == 200) {
        final responseBody = jsonDecode(chatbotResponse.body);
        return responseBody['reply'];
      } else {
        debugPrint("Chatbot error: ${chatbotResponse.statusCode}");
        return "Error: ${chatbotResponse.statusCode}";
      }
    } catch (e) {
      debugPrint("Error: $e");
      return "Error: $e";
    }
  }

  static Future<void> sendMessage(String message) async {
    if (message.trim().isNotEmpty) {
      // Add user message to chat history
      chatHistory.add(ChatMessage(text: message, isUser: true));
      chatHistoryNotifier.value = List.from(chatHistory);

      // Clear input
      inputController.clear();

      // Show loading message
      chatHistory.add(ChatMessage(text: "Typing...", isUser: false));
      chatHistoryNotifier.value = List.from(chatHistory);

      // Get AI response
      final response = await chatWithAI(AppConfig.chatbotUrl, message);

      // Remove loading message and add actual response
      chatHistory.removeLast();
      chatHistory.add(ChatMessage(text: response, isUser: false));
      chatHistoryNotifier.value = List.from(chatHistory);
    }
  }

  static Future _speak(String text) async {
    if (!_isTTSInitialized) return;

    try {
      await flutterTts.stop();
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS error: $e");
    }
  }

  // Speech listening
  static Future<void> startListening() async {
    if (!_speechEnabled) return;

    try {
      _isListeningNotifier.value = true;

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedText = result.recognizedWords.trim();
            if (recognizedText.isNotEmpty) {
              inputController.text = recognizedText;
              inputController.selection = TextSelection.fromPosition(
                TextPosition(offset: inputController.text.length),
              );
              stopListening();
            }
          } else {
            inputController.text = result.recognizedWords;
            inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: inputController.text.length),
            );
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 10),
        localeId: "en_AU",
      );
    } catch (e) {
      debugPrint("Error starting speech recognition: $e");
      _isListeningNotifier.value = false;
    }
  }

  static Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListeningNotifier.value = false;
      debugPrint("Stopped speech recognition");
    } catch (e) {
      debugPrint("Error stopping speech recognition: $e");
      _isListeningNotifier.value = false;
    }
  }

  // Function to build the chatbot page
  static Container chatbotPage(BuildContext context) {
    // Initialize chat when page is built
    initializeChat();

    // Initialize TTS
    initializeTTS();

    // Initialize speech
    initializeSpeech();

    // Create a ScrollController for the ListView
    final ScrollController scrollController = ScrollController();

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
          Expanded(child: _buildChatMessages(context, scrollController)),

          // Input area
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Shared.inputContainer(
                        double.infinity,
                        'Ask me anything',
                        inputController,
                        onSubmitted: (value) async {
                          await sendMessage(value);
                        },
                      ),
                    ),
                    _buildMicButton(),
                  ],
                ),
                // Speech listening indicator
                ValueListenableBuilder<bool>(
                  valueListenable: _isListeningNotifier,
                  builder: (context, isListening, child) {
                    if (isListening) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Listening...',
                          style: Shared.fontStyle(
                            16,
                            FontWeight.w400,
                            Colors.red,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChatMessages(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return ValueListenableBuilder<List<ChatMessage>>(
      valueListenable: chatHistoryNotifier,
      builder: (context, chatHistory, child) {
        _buildScrollToBottom(context, scrollController, chatHistory);
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: chatHistory.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(context, chatHistory[index]);
          },
        );
      },
    );
  }

  static Widget _buildMessageItem(BuildContext context, ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Shared.orange : Shared.lightGray2,
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: Shared.fontStyle(
                24,
                FontWeight.w400,
                message.isUser ? Shared.bgColor : Shared.black,
              ),
            ),
            if (!message.isUser) _buildSpeakerButton(message.text),
          ],
        ),
      ),
    );
  }

  static Widget _buildSpeakerButton(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/speaker.svg',
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(Shared.orange, BlendMode.srcIn),
        ),
        onPressed: () => _speak(text),
      ),
    );
  }

  static Widget _buildMicButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isListeningNotifier,
        builder: (context, isListening, child) {
          return Container(
            decoration: isListening
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.2),
                  )
                : null,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/mic.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  isListening
                      ? Colors.red
                      : _speechEnabled
                      ? Shared.orange
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: _speechEnabled
                  ? () {
                      if (isListening) {
                        stopListening();
                      } else {
                        startListening();
                      }
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  static Widget _buildScrollToBottom(
    BuildContext context,
    ScrollController scrollController,
    List<ChatMessage> chatHistory,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && chatHistory.isNotEmpty) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    return const SizedBox.shrink();
  }
}
