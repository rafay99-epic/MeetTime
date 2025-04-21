import 'package:flutter/material.dart';
import 'package:meettime/core/repositories/chatbot_repo.dart';

class ChatbotProvider with ChangeNotifier {
  ChatbotRepository? _repository;
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _hasValidKey = false;
  final String? _initialApiKey;

  ChatbotProvider({required String? apiKey}) : _initialApiKey = apiKey {
    _initializeRepository(apiKey);
  }

  void _initializeRepository(String? apiKey) {
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        _repository = ChatbotRepository(apiKey: apiKey.trim());
        _hasValidKey = true;
      } catch (e) {
        _repository = null;
        _hasValidKey = false;
      }
    } else {
      _repository = null;
      _hasValidKey = false;
    }
  }

  List<Map<String, String>> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get hasValidKey => _hasValidKey;

  void updateApiKey(String? newApiKey) {
    if (_initialApiKey == newApiKey) return;

    _initializeRepository(newApiKey);
    _messages.clear();
    _isTyping = false;
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    if (!_hasValidKey || _repository == null) {
      _messages.add({"role": "user", "content": userMessage});
      _messages.add({
        "role": "ai",
        "content":
            "Error: Chatbot is not configured. Please set a valid API key in settings."
      });
      notifyListeners();
      return;
    }

    _messages.add({"role": "user", "content": userMessage});
    _isTyping = true;
    notifyListeners();

    try {
      final aiResponse = await _repository!.generateResponse(userMessage);
      _messages.add({"role": "ai", "content": aiResponse});
    } catch (e) {
      _messages.add({
        "role": "ai",
        "content": "Error: Unable to generate a response. Please try again."
      });
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
