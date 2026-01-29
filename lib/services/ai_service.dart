import '../models/chat_message.dart';
import '../utils/crisis_detector.dart';
import 'package:uuid/uuid.dart';

class AIService {
  final _uuid = const Uuid();
  
  // Generate AI response (mock implementation - replace with actual API call)
  Future<ChatMessage> generateResponse({
    required String userId,
    required String userMessage,
    List<ChatMessage>? conversationHistory,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check for crisis
    final isCrisis = CrisisDetector.detectCrisis(userMessage);
    final crisisSeverity = CrisisDetector.getCrisisSeverity(userMessage);
    
    String responseContent;
    
    if (isCrisis) {
      // Priority: Crisis response
      responseContent = CrisisDetector.getCrisisResponse(crisisSeverity);
    } else {
      // Generate contextual response based on message content
      responseContent = _generateContextualResponse(userMessage);
    }
    
    return ChatMessage(
      id: _uuid.v4(),
      userId: userId,
      content: responseContent,
      isUser: false,
      isCrisisDetected: isCrisis,
      crisisSeverity: crisisSeverity,
    );
  }
  
  // Generate contextual response (mock - replace with actual AI)
  String _generateContextualResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Anxiety-related
    if (lowerMessage.contains('anxious') || lowerMessage.contains('anxiety') || lowerMessage.contains('worried')) {
      return '''I understand you're feeling anxious. Anxiety is a natural response, but it can be overwhelming. Here are some techniques that might help:

• Try the 4-7-8 breathing technique: Breathe in for 4 counts, hold for 7, exhale for 8
• Ground yourself using the 5-4-3-2-1 method: Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste
• Practice progressive muscle relaxation

Would you like to try a guided breathing exercise or meditation?''';
    }
    
    // Depression-related
    if (lowerMessage.contains('depressed') || lowerMessage.contains('depression') || lowerMessage.contains('sad')) {
      return '''I hear that you're going through a difficult time. Depression can make everything feel heavy and overwhelming. Remember that what you're feeling is valid, and you're not alone.

Some things that might help:
• Start small - even tiny accomplishments matter
• Try to maintain a routine, even if it's simple
• Reach out to someone you trust
• Consider professional support if you haven't already

What's one small thing you could do today to take care of yourself?''';
    }
    
    // Stress-related
    if (lowerMessage.contains('stress') || lowerMessage.contains('overwhelmed') || lowerMessage.contains('pressure')) {
      return '''Feeling stressed and overwhelmed is challenging. Let's work on breaking things down into manageable pieces.

Try these stress-management techniques:
• Make a list and prioritize - what needs attention first?
• Take regular breaks, even just 5 minutes
• Practice mindfulness or meditation
• Physical activity, even a short walk, can help

What's the main source of stress right now? Sometimes talking through it can help clarify things.''';
    }
    
    // Sleep-related
    if (lowerMessage.contains('sleep') || lowerMessage.contains('insomnia') || lowerMessage.contains('tired')) {
      return '''Sleep difficulties can really impact how we feel. Good sleep hygiene can make a big difference:

• Maintain a consistent sleep schedule
• Create a relaxing bedtime routine
• Avoid screens 1 hour before bed
• Keep your bedroom cool, dark, and quiet
• Try a guided sleep meditation

Would you like me to suggest some sleep meditation sessions?''';
    }
    
    // Positive messages
    if (lowerMessage.contains('happy') || lowerMessage.contains('good') || lowerMessage.contains('great') || lowerMessage.contains('better')) {
      return '''That's wonderful to hear! It's important to acknowledge and celebrate the positive moments. 

What's contributing to these good feelings? Recognizing what helps us feel better can be valuable for future reference.

Keep nurturing this positive energy! 🌟''';
    }
    
    // Gratitude
    if (lowerMessage.contains('grateful') || lowerMessage.contains('thankful') || lowerMessage.contains('blessed')) {
      return '''Practicing gratitude is a powerful tool for mental wellness. It's beautiful that you're taking time to appreciate the good in your life.

Research shows that regular gratitude practice can:
• Improve mood and overall well-being
• Enhance relationships
• Reduce stress and anxiety
• Improve sleep quality

Consider keeping a daily gratitude journal to build on this practice!''';
    }
    
    // Default supportive response
    return '''Thank you for sharing that with me. I'm here to listen and support you. 

Mental health is a journey, and it's okay to have ups and downs. What you're feeling is valid, and reaching out is a sign of strength.

Is there something specific you'd like to talk about or explore? I can help with:
• Coping strategies for anxiety or stress
• Mood tracking and insights
• Meditation and mindfulness techniques
• Journaling prompts
• General mental health resources

How can I best support you right now?''';
  }
  
  // Generate journal insight
  Future<String> generateJournalInsight(String content, double sentimentScore) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (sentimentScore >= 0.5) {
      return 'Your entry reflects a positive mindset. Continue nurturing these feelings through gratitude and self-care practices.';
    } else if (sentimentScore >= 0.2) {
      return 'You seem to be in a balanced emotional state. Keep up with your self-care routines and stay mindful of your needs.';
    } else if (sentimentScore >= -0.2) {
      return 'Your emotions appear neutral today. It\'s okay to have days like this. Consider what might bring you more joy or peace.';
    } else if (sentimentScore >= -0.5) {
      return 'It seems you\'re experiencing some challenges. Remember to be kind to yourself. Consider reaching out to a friend or practicing self-compassion.';
    } else {
      return 'Your entry suggests you\'re going through a difficult time. Please remember that support is available. Consider talking to a mental health professional if these feelings persist.';
    }
  }
  
  // Generate mood insights
  Future<String> generateMoodInsights(List<int> moodLevels) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (moodLevels.isEmpty) {
      return 'Start tracking your mood daily to see patterns and insights.';
    }
    
    final average = moodLevels.reduce((a, b) => a + b) / moodLevels.length;
    final trend = _calculateTrend(moodLevels);
    
    String insight = '';
    
    if (average >= 7) {
      insight = 'Your mood has been generally positive! ';
    } else if (average >= 5) {
      insight = 'Your mood has been moderate. ';
    } else {
      insight = 'Your mood has been lower than usual. ';
    }
    
    if (trend > 0.5) {
      insight += 'Great news - there\'s an upward trend! Keep doing what\'s working for you.';
    } else if (trend < -0.5) {
      insight += 'There\'s a downward trend. Consider what might be affecting your mood and reach out for support if needed.';
    } else {
      insight += 'Your mood has been relatively stable.';
    }
    
    return insight;
  }
  
  double _calculateTrend(List<int> values) {
    if (values.length < 2) return 0;
    
    final firstHalf = values.sublist(0, values.length ~/ 2);
    final secondHalf = values.sublist(values.length ~/ 2);
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    return secondAvg - firstAvg;
  }
}
