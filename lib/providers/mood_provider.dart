import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';

class MoodProvider with ChangeNotifier {
  final _uuid = const Uuid();
  final ApiService _apiService = ApiService();
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MoodProvider() {
    _loadEntries();
  }

  /// Load entries: first from local cache, then sync from backend
  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    // Load from local Hive first for instant data
    try {
      final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
      _entries = box.values.toList();
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading local mood entries: $e');
    }

    // Then sync from backend
    await fetchFromBackend();

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch mood history from backend and update local cache
  Future<void> fetchFromBackend() async {
    try {
      final moodsData = await _apiService.getMoodHistory(days: 90);
      final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);

      final backendEntries = moodsData.map((moodData) {
        return MoodEntry(
          id: moodData['id']?.toString() ?? _uuid.v4(),
          userId: moodData['user_id']?.toString() ?? '',
          moodLevel: _moodStringToLevel(moodData['mood']?.toString() ?? ''),
          notes: moodData['note'],
          timestamp: moodData['created_at'] != null
              ? DateTime.parse(moodData['created_at'])
              : DateTime.now(),
          stressLevel: moodData['intensity'],
        );
      }).toList();

      // Update local cache
      await box.clear();
      for (final entry in backendEntries) {
        await box.put(entry.id, entry);
      }

      _entries = backendEntries;
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _error = null;
    } catch (e) {
      debugPrint('Error fetching mood history from backend: $e');
      _error = e.toString();
      // Keep using local data if backend fails
    }
    notifyListeners();
  }

  /// Add a mood entry - sends to backend and saves locally
  Future<void> addEntry(MoodEntry entry) async {
    try {
      // Send to backend
      final response = await _apiService.logMood(
        mood: _moodLevelToString(entry.moodLevel),
        // Ensure intensity is within 1-10 for backend compatibility
        intensity: (entry.stressLevel != null) 
            ? (entry.stressLevel! / 10).clamp(1, 10).toInt() 
            : entry.moodLevel,
        note: entry.notes ?? entry.triggers.join(', '),
      );

      // Update entry with backend ID
      final backendData = response['data'];
      final savedEntry = entry.copyWith(
        id: backendData?['id']?.toString() ?? entry.id,
      );

      // Save to local cache
      final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
      await box.put(savedEntry.id, savedEntry);
      
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = savedEntry;
      } else {
        _entries.insert(0, savedEntry);
      }
      
      _error = null;
    } catch (e) {
      debugPrint('Error saving mood to backend: $e');
      _error = 'Backend sync failed, saved locally';
      
      // Save locally anyway for offline support
      final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
      await box.put(entry.id, entry);
      if (!_entries.any((e) => e.id == entry.id)) {
        _entries.insert(0, entry);
      }
      
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _error = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  Future<void> updateEntry(MoodEntry entry) async {
    final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
    await box.put(entry.id, entry);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
    await box.delete(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Get entries for a specific date range
  List<MoodEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  // Get today's entry
  MoodEntry? getTodayEntry() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    try {
      return _entries.firstWhere(
        (entry) => entry.timestamp.isAfter(today) && entry.timestamp.isBefore(tomorrow),
      );
    } catch (_) {
      return null;
    }
  }

  // Get average mood for last N days
  double getAverageMood(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final recentEntries = getEntriesForDateRange(startDate, now);

    if (recentEntries.isEmpty) return 0;

    final sum = recentEntries.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    return sum / recentEntries.length;
  }

  // Get mood streak (consecutive days with entries)
  int getMoodStreak() {
    if (_entries.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final dayStart = DateTime(currentDate.year, currentDate.month, currentDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final hasEntry = _entries.any((entry) =>
          entry.timestamp.isAfter(dayStart) && entry.timestamp.isBefore(dayEnd));

      if (hasEntry) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Helper: Convert mood level (1-10) to a backend-compatible string
  // Matches backend Validators.moodType: happy, sad, anxious, angry, calm, stressed, etc.
  String _moodLevelToString(int level) {
    if (level <= 2) return 'sad';
    if (level <= 4) return 'stressed';
    if (level <= 6) return 'calm';
    if (level <= 8) return 'happy';
    return 'excited';
  }

  // Helper: Convert backend mood string back to a level (1-10)
  int _moodStringToLevel(String mood) {
    switch (mood.toLowerCase()) {
      case 'sad':
        return 2;
      case 'stressed':
        return 4;
      case 'calm':
        return 6;
      case 'happy':
        return 8;
      case 'excited':
        return 10;
      case 'very_low':
        return 1;
      case 'low':
        return 3;
      case 'moderate':
        return 5;
      case 'good':
        return 7;
      case 'excellent':
        return 9;
      default:
        final parsed = int.tryParse(mood);
        if (parsed != null) return parsed.clamp(1, 10);
        return 5;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
