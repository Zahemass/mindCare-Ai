import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';
import '../models/meditation_session.dart';
import '../models/chat_message.dart';
import '../models/goal.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  
  bool _initialized = false;
  
  // Initialize Hive and register adapters
  Future<void> initialize() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Register adapters (these will be generated)
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(MoodEntryAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(MeditationSessionAdapter());
    Hive.registerAdapter(MeditationHistoryAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(GoalAdapter());
    
    // Open boxes
    await Hive.openBox<UserModel>(AppConfig.userBoxKey);
    await Hive.openBox<MoodEntry>(AppConfig.moodBoxKey);
    await Hive.openBox<JournalEntry>(AppConfig.journalBoxKey);
    await Hive.openBox(AppConfig.meditationBoxKey);
    await Hive.openBox<ChatMessage>(AppConfig.chatBoxKey);
    await Hive.openBox<Goal>(AppConfig.goalsBoxKey);
    await Hive.openBox(AppConfig.settingsBoxKey);
    
    _initialized = true;
  }
  
  // Get box
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
  
  // User operations
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(AppConfig.userBoxKey);
    await box.put('current_user', user);
  }
  
  UserModel? getCurrentUser() {
    final box = Hive.box<UserModel>(AppConfig.userBoxKey);
    return box.get('current_user');
  }
  
  Future<void> deleteUser() async {
    final box = Hive.box<UserModel>(AppConfig.userBoxKey);
    await box.delete('current_user');
  }
  
  // Password storage (hashed)
  Future<void> savePassword(String email, String hashedPassword) async {
    final box = Hive.box(AppConfig.settingsBoxKey);
    await box.put('password_$email', hashedPassword);
  }
  
  String? getPassword(String email) {
    final box = Hive.box(AppConfig.settingsBoxKey);
    return box.get('password_$email');
  }
  
  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(AppConfig.settingsBoxKey);
    await box.put(key, value);
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(AppConfig.settingsBoxKey);
    return box.get(key, defaultValue: defaultValue);
  }
  
  // Chat operations
  Future<void> saveChatMessage(ChatMessage message) async {
    final box = Hive.box<ChatMessage>(AppConfig.chatBoxKey);
    await box.add(message);
  }

  List<ChatMessage> getChatMessages() {
    final box = Hive.box<ChatMessage>(AppConfig.chatBoxKey);
    return box.values.toList();
  }

  Future<void> clearChatMessages() async {
    final box = Hive.box<ChatMessage>(AppConfig.chatBoxKey);
    await box.clear();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await Hive.box<UserModel>(AppConfig.userBoxKey).clear();
    await Hive.box<MoodEntry>(AppConfig.moodBoxKey).clear();
    await Hive.box<JournalEntry>(AppConfig.journalBoxKey).clear();
    await Hive.box(AppConfig.meditationBoxKey).clear();
    await Hive.box<ChatMessage>(AppConfig.chatBoxKey).clear();
    await Hive.box<Goal>(AppConfig.goalsBoxKey).clear();
    await Hive.box(AppConfig.settingsBoxKey).clear();
  }
  
  // Close all boxes
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
