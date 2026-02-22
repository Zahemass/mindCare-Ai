import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get error => _error;

  ChatProvider() {
    _loadMessages();
  }

  /// Load messages: first from local cache, then from backend
  Future<void> _loadMessages() async {
    // Load local messages first for instant display
    _messages = _storageService.getChatMessages();
    notifyListeners();

    // Sync from backend
    await fetchFromBackend();
  }

  /// Fetch chat history from backend
  Future<void> fetchFromBackend() async {
    try {
      final chatsData = await _apiService.getChatHistory(limit: 100);

      if (chatsData.isNotEmpty) {
        // Clear local cache and rebuild from backend
        await _storageService.clearChatMessages();
        _messages = [];

        for (final chatData in chatsData.reversed) {
          // Each backend chat has user_message and ai_response
          final userMsg = ChatMessage(
            id: '${chatData['id']}_user',
            userId: chatData['user_id']?.toString() ?? '',
            content: chatData['user_message'] ?? '',
            isUser: true,
            timestamp: chatData['created_at'] != null
                ? DateTime.parse(chatData['created_at'])
                : DateTime.now(),
          );

          final aiMsg = ChatMessage(
            id: '${chatData['id']}_ai',
            userId: chatData['user_id']?.toString() ?? '',
            content: chatData['ai_response'] ?? '',
            isUser: false,
            timestamp: chatData['created_at'] != null
                ? DateTime.parse(chatData['created_at']).add(const Duration(seconds: 1))
                : DateTime.now(),
          );

          _messages.add(userMsg);
          _messages.add(aiMsg);

          await _storageService.saveChatMessage(userMsg);
          await _storageService.saveChatMessage(aiMsg);
        }

        _error = null;
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
      _error = e.toString();
      // Keep using local messages
    }
    notifyListeners();
  }

  /// Send a text message to the backend AI
  Future<void> sendMessage(String userId, String content) async {
    if (content.trim().isEmpty) return;

    // Create and display user message immediately
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
      // Send to backend and get AI response
      final response = await _apiService.sendTextMessage(content);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: response['message'] ?? 'I\'m here to help.',
        isUser: false,
        timestamp: DateTime.now(),
        isCrisisDetected: (response['riskLevel'] ?? 'low') == 'high',
        crisisSeverity: _riskLevelToSeverity(response['riskLevel']),
      );

      _messages.add(aiMessage);
      await _storageService.saveChatMessage(aiMessage);
      _error = null;
    } on ApiException catch (e) {
      debugPrint('API error in chat: $e');
      _error = e.message;
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: "I'm sorry, I'm having trouble connecting right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _storageService.saveChatMessage(errorMessage);
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      _error = 'Network error';
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: "I'm sorry, I'm having trouble connecting right now. Please check your connection and try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _storageService.saveChatMessage(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Send a voice message to the backend AI
  Future<void> sendVoiceMessage(String userId, String filePath) async {
    // Create and display user voice message placeholder
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      userId: userId,
      content: '🎤 Voice message',
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
      final audioFile = File(filePath);
      print('📡 Sending voice message: ${audioFile.path}');
      final response = await _apiService.sendVoiceMessage(audioFile);

      // Update user message with the transcription
      final transcription = response['transcription'] ?? 'Voice message';
      final updatedUserMessage = ChatMessage(
        id: userMessage.id,
        userId: userId,
        content: '🎤 $transcription',
        isUser: true,
        timestamp: userMessage.timestamp,
      );

      final userIndex = _messages.indexWhere((m) => m.id == userMessage.id);
      if (userIndex != -1) {
        _messages[userIndex] = updatedUserMessage;
      }

      // Add AI response
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: response['message'] ?? "I'm here to help.",
        isUser: false,
        timestamp: DateTime.now(),
        isCrisisDetected: (response['riskLevel'] ?? 'low') == 'high',
        crisisSeverity: _riskLevelToSeverity(response['riskLevel']),
      );

      _messages.add(aiMessage);
      await _storageService.saveChatMessage(aiMessage);
      _error = null;
    } on ApiException catch (e) {
      debugPrint('API error in voice chat: $e');
      _error = e.message;
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: "I couldn't process your voice message. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _storageService.saveChatMessage(errorMessage);
    } catch (e) {
      debugPrint('Error sending voice message: $e');
      _error = 'Voice message failed';
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        userId: userId,
        content: "I'm sorry, I couldn't process your voice message. Please check your connection and try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _storageService.saveChatMessage(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();

      // Clean up the audio file
      try {
        final audioFile = File(filePath);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      } catch (_) {}
    }
  }

  Future<void> clearChat() async {
    await _storageService.clearChatMessages();
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convert backend risk level string to severity integer
  int _riskLevelToSeverity(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }
}
