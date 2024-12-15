import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _silenceTimer;
  final int _silenceThreshold = 2; // seconds of silence before stopping

  bool _isListening = false;
  String _inputText = '';
  String _responseText = '';
  String _selectedLanguage = 'English';
  Map<String, dynamic> _responses = {};
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _loadResponses();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage(_getLocaleId());
  }

  Future<void> _loadResponses() async {
    try {
      final String response = await rootBundle.loadString('assets/chat/$_selectedLanguage.json');
      setState(() {
        _responses = json.decode(response);
      });
      // Add welcome message
      _addMessage("Hello! I'm Vikrant. How can I help you today?", isUser: false);
    } catch (e) {
      print('Error loading responses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.android, color: Colors.white),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vikrant',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                icon: Icon(Icons.language, color: Colors.blue),
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                items: ['English', 'Hindi']
                    .map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[index];
                },
              ),
            ),
            _isListening
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Listening...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _handleSubmitted(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _handleSubmitted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });

      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
            _silenceTimer?.cancel();
            if (!result.finalResult) {
              _silenceTimer = Timer(Duration(seconds: _silenceThreshold), () {
                _stopListening();
              });
            }
          });
        },
        onSoundLevelChange: (level) {
          _silenceTimer?.cancel();
          _silenceTimer = Timer(Duration(seconds: _silenceThreshold), () {
            _stopListening();
          });
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: _getLocaleId(),
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    _silenceTimer?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  void _handleSubmitted() {
    if (_textController.text.trim().isEmpty) return;

    final message = _textController.text;
    _inputText = message;
    _addMessage(message, isUser: true);
    _generateResponse(message);

    _textController.clear();
    _scrollToBottom();
  }

  void _generateResponse(String input) async {
    String response;

    // Normalize input by trimming spaces
    String normalizedInput = input.trim();
    print("Normalized Input: $normalizedInput"); // Debug: Check the input after trimming

    // Attempt case-insensitive and punctuation-tolerant match
    String? matchingKey = _responses.keys.firstWhere(
          (key) => key.toLowerCase() == normalizedInput.toLowerCase(),
      orElse: () => "",
    );
    print("Matching Key: $matchingKey"); // Debug: Check the matching key

    if (matchingKey.isNotEmpty) {
      // Fetch response for the matched key
      response = _responses[matchingKey] ?? 'I am sorry, I do not understand.';
    } else {
      response = 'I am sorry, I do not understand.';
    }
    print("Generated Response: $response"); // Debug: Check the generated response

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _responseText = response;
      _addMessage(response, isUser: false);
    });

    // Speak the response
    await _flutterTts.setLanguage(_getLocaleId());
    print("Selected Locale ID: ${_getLocaleId()}"); // Debug: Check the locale ID
    await _flutterTts.speak(response);
    print("Speaking response: $response"); // Debug: Check if speaking is triggered

    _scrollToBottom();
  }

  String _getLocaleId() {
    switch (_selectedLanguage) {
      case 'Hindi':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }

  void _addMessage(String text, {bool isUser = false}) {
    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _flutterTts.stop();
    _speechToText.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(),
        super(key: key);

  String formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Icon(Icons.android, color: Colors.white, size: 18),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formatTime(timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
