class SentimentAnalyzer {
  // Analyze sentiment of text (returns score from -1.0 to 1.0)
  // -1.0 = Very negative, 0.0 = Neutral, 1.0 = Very positive
  static double analyzeSentiment(String text) {
    final lowerText = text.toLowerCase();
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    // Count positive words
    for (final word in _positiveWords) {
      if (lowerText.contains(word)) {
        positiveCount++;
      }
    }
    
    // Count negative words
    for (final word in _negativeWords) {
      if (lowerText.contains(word)) {
        negativeCount++;
      }
    }
    
    // Calculate sentiment score
    final totalWords = positiveCount + negativeCount;
    if (totalWords == 0) return 0.0;
    
    final score = (positiveCount - negativeCount) / totalWords;
    return score.clamp(-1.0, 1.0);
  }
  
  // Get sentiment label
  static String getSentimentLabel(double score) {
    if (score >= 0.5) return 'Very Positive';
    if (score >= 0.2) return 'Positive';
    if (score >= -0.2) return 'Neutral';
    if (score >= -0.5) return 'Negative';
    return 'Very Negative';
  }
  
  // Get sentiment emoji
  static String getSentimentEmoji(double score) {
    if (score >= 0.5) return '😊';
    if (score >= 0.2) return '🙂';
    if (score >= -0.2) return '😐';
    if (score >= -0.5) return '😕';
    return '😢';
  }
  
  // Positive words
  static const List<String> _positiveWords = [
    'happy', 'joy', 'love', 'excellent', 'good', 'great', 'wonderful',
    'fantastic', 'amazing', 'beautiful', 'peaceful', 'calm', 'relaxed',
    'grateful', 'thankful', 'blessed', 'excited', 'hopeful', 'optimistic',
    'confident', 'proud', 'accomplished', 'successful', 'better', 'improved',
    'progress', 'growth', 'positive', 'cheerful', 'delighted', 'pleased',
    'content', 'satisfied', 'comfortable', 'safe', 'secure', 'loved',
    'appreciated', 'valued', 'supported', 'encouraged', 'motivated',
    'inspired', 'energized', 'refreshed', 'relieved', 'free', 'liberated',
  ];
  
  // Negative words
  static const List<String> _negativeWords = [
    'sad', 'depressed', 'anxious', 'worried', 'stressed', 'angry', 'frustrated',
    'upset', 'hurt', 'pain', 'suffering', 'terrible', 'awful', 'horrible',
    'bad', 'worse', 'worst', 'difficult', 'hard', 'struggle', 'struggling',
    'overwhelmed', 'exhausted', 'tired', 'drained', 'hopeless', 'helpless',
    'worthless', 'useless', 'failure', 'failed', 'disappointed', 'discouraged',
    'lonely', 'isolated', 'alone', 'abandoned', 'rejected', 'unwanted',
    'scared', 'afraid', 'fearful', 'terrified', 'nervous', 'tense',
    'uncomfortable', 'uneasy', 'distressed', 'troubled', 'concerned',
  ];
  
  // Extract dominant emotions from text
  static List<String> extractEmotions(String text) {
    final lowerText = text.toLowerCase();
    final emotions = <String>[];
    
    final emotionKeywords = {
      'Happy': ['happy', 'joy', 'cheerful', 'delighted', 'pleased'],
      'Sad': ['sad', 'depressed', 'down', 'unhappy', 'miserable'],
      'Anxious': ['anxious', 'worried', 'nervous', 'tense', 'uneasy'],
      'Angry': ['angry', 'frustrated', 'annoyed', 'irritated', 'mad'],
      'Calm': ['calm', 'peaceful', 'relaxed', 'tranquil', 'serene'],
      'Stressed': ['stressed', 'overwhelmed', 'pressure', 'burden'],
      'Hopeful': ['hopeful', 'optimistic', 'encouraged', 'positive'],
      'Lonely': ['lonely', 'isolated', 'alone', 'abandoned'],
      'Grateful': ['grateful', 'thankful', 'blessed', 'appreciated'],
      'Confused': ['confused', 'uncertain', 'unsure', 'lost'],
    };
    
    for (final entry in emotionKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          emotions.add(entry.key);
          break;
        }
      }
    }
    
    return emotions;
  }
  
  // Generate insights from sentiment analysis
  static String generateInsight(double sentimentScore, List<String> emotions) {
    final sentiment = getSentimentLabel(sentimentScore);
    
    if (sentimentScore >= 0.5) {
      return 'Your entry reflects a very positive mindset. Keep nurturing these positive feelings!';
    } else if (sentimentScore >= 0.2) {
      return 'You seem to be in a good place emotionally. Continue with what\'s working for you.';
    } else if (sentimentScore >= -0.2) {
      return 'Your emotions seem balanced. It\'s okay to have neutral days.';
    } else if (sentimentScore >= -0.5) {
      return 'You might be experiencing some challenges. Consider practicing self-care or reaching out for support.';
    } else {
      return 'It seems you\'re going through a difficult time. Remember, it\'s okay to ask for help. Consider talking to a mental health professional.';
    }
  }
}
