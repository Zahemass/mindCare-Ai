import 'api_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final ApiService _apiService = ApiService();

  /// Send a text message to the AI companion via the backend
  /// Returns the AI response map including { message, emotion, riskLevel }
  Future<Map<String, dynamic>> generateResponse(String userMessage) async {
    try {
      final response = await _apiService.sendTextMessage(userMessage);
      return {
        'message': response['message'] ?? "I'm here to help you.",
        'emotion': response['emotion'],
        'riskLevel': response['riskLevel'] ?? 'low',
        'isCrisis': (response['riskLevel'] ?? 'low') == 'high',
      };
    } catch (e) {
      print('AI Service error: $e');
      return {
        'message': "I'm having trouble connecting right now. Please try again in a moment.",
        'emotion': null,
        'riskLevel': 'low',
        'isCrisis': false,
      };
    }
  }

  /// Generate AI insight for a journal entry via the backend
  /// Returns a map with { emotion, insight }
  Future<Map<String, dynamic>> generateJournalInsight(String journalContent) async {
    try {
      final response = await _apiService.getJournalAIInsight(journalContent);
      return {
        'emotion': response['emotion'] ?? 'neutral',
        'insight': response['insight'] ?? 'Keep reflecting on your thoughts.',
      };
    } catch (e) {
      print('Journal AI Insight error: $e');
      return {
        'emotion': 'neutral',
        'insight': 'Unable to generate insight right now. Keep journaling!',
      };
    }
  }

  /// Check if the message contains crisis indicators
  /// (The backend handles this via its emotion service, but this
  ///  can also do a quick local check for immediate UI feedback)
  bool detectCrisis(String message) {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end my life', 'want to die',
      'hurt myself', 'self harm', 'no reason to live', 'better off dead',
    ];
    final lowerMessage = message.toLowerCase();
    return crisisKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}
