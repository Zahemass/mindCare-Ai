import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // App Information
  static const String appName = 'MindCare AI';
  static const String appVersion = '1.0.0';
  
  // Backend API Configuration
  // Reads from .env file — update API_BASE_URL in .env to change
  // Fallback: http://localhost:5000/api
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';

  // AI API Configuration (handled by backend, kept for reference)
  static const String aiApiBaseUrl = 'https://api.example.com';
  static const String aiApiKey = '';
  
  // Feature Flags
  static const bool enablePremiumFeatures = true;
  static const bool enableAIChat = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  
  // Mood Settings
  static const int moodLevels = 10;
  static const List<String> moodEmojis = ['😢', '😞', '😕', '😐', '🙂', '😊', '😄', '😁', '🤗', '🥰'];
  
  // Meditation Settings
  static const List<int> meditationDurations = [5, 10, 15, 20, 30];
  
  // Notification Settings
  static const String defaultMoodReminderTime = '20:00';
  static const String defaultMeditationReminderTime = '08:00';
  
  // Emergency Contacts (Customize for your region)
  static const Map<String, String> emergencyHotlines = {
    'National Suicide Prevention Lifeline (US)': '988',
    'Crisis Text Line (US)': 'Text HOME to 741741',
    'SAMHSA National Helpline (US)': '1-800-662-4357',
    'International Association for Suicide Prevention': 'https://www.iasp.info/resources/Crisis_Centres/',
  };
  
  // Crisis Keywords for Detection
  static const List<String> crisisKeywords = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'hurt myself',
    'self harm',
    'no reason to live',
    'better off dead',
  ];
  
  // Storage Keys
  static const String userBoxKey = 'user_box';
  static const String moodBoxKey = 'mood_box';
  static const String journalBoxKey = 'journal_box';
  static const String meditationBoxKey = 'meditation_box';
  static const String chatBoxKey = 'chat_box';
  static const String settingsBoxKey = 'settings_box';
  static const String goalsBoxKey = 'goals_box';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Premium Features
  static const int freeJournalEntriesLimit = 10;
  static const int freeMeditationSessionsLimit = 5;
  static const bool freeAIChatEnabled = true;
  static const int freeAIChatMessagesPerDay = 20;
}
