import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    _messages = _storageService.getChatMessages();
    notifyListeners();
  }

  Future<void> sendMessage(String userId, String content) async {
    if (content.trim().isEmpty) return;

    // Create user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      userId: userId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _storageService.saveChatMessage(userMessage);
    notifyListeners();

    // Set typing state
    _isTyping = true;
    notifyListeners();

    try {
      // Get AI response
      final aiResponse = await _aiService.generateResponse(
        userId: userId,
        userMessage: content,
        conversationHistory: _messages,
      );

      _messages.add(aiResponse);
      await _storageService.saveChatMessage(aiResponse);
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: "I're sorry, I'm having trouble connecting right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    await _storageService.clearChatMessages();
    _messages = [];
    notifyListeners();
  }
}
