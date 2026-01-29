import '../config/app_config.dart';

class CrisisDetector {
  // Detect crisis keywords in text
  static bool detectCrisis(String text) {
    final lowerText = text.toLowerCase();
    
    for (final keyword in AppConfig.crisisKeywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
  
  // Get crisis severity level (1-3)
  // 1 = Low concern, 2 = Moderate concern, 3 = High concern
  static int getCrisisSeverity(String text) {
    final lowerText = text.toLowerCase();
    
    // High severity keywords
    final highSeverityKeywords = [
      'suicide',
      'kill myself',
      'end my life',
      'want to die',
      'better off dead',
    ];
    
    // Moderate severity keywords
    final moderateSeverityKeywords = [
      'hurt myself',
      'self harm',
      'no reason to live',
      'can\'t go on',
      'give up',
    ];
    
    // Check for high severity
    for (final keyword in highSeverityKeywords) {
      if (lowerText.contains(keyword)) {
        return 3;
      }
    }
    
    // Check for moderate severity
    for (final keyword in moderateSeverityKeywords) {
      if (lowerText.contains(keyword)) {
        return 2;
      }
    }
    
    // Check for any crisis keyword
    if (detectCrisis(text)) {
      return 1;
    }
    
    return 0;
  }
  
  // Get appropriate crisis response message
  static String getCrisisResponse(int severity) {
    switch (severity) {
      case 3:
        return '''I'm very concerned about what you've shared. Your safety is the top priority. Please reach out to a crisis helpline immediately:

• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741
• Call 911 if you're in immediate danger

These services are available 24/7 and can provide immediate support. You don't have to face this alone.''';
      
      case 2:
        return '''I hear that you're going through a difficult time. It's important to talk to someone who can help:

• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741
• SAMHSA National Helpline: 1-800-662-4357

Consider reaching out to a mental health professional or trusted person in your life. You deserve support.''';
      
      case 1:
        return '''It sounds like you're struggling. Remember that help is available:

• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741

If you're having thoughts of self-harm, please reach out to a professional. Would you like to talk about what's troubling you?''';
      
      default:
        return '';
    }
  }
  
  // Check if message requires immediate intervention
  static bool requiresImmediateIntervention(String text) {
    return getCrisisSeverity(text) >= 2;
  }
}
