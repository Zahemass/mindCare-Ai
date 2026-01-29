import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../config/app_config.dart';

class MoodProvider with ChangeNotifier {
  final _uuid = const Uuid();
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  
  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  
  MoodProvider() {
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();
    
    final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
    _entries = box.values.toList();
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> addEntry(MoodEntry entry) async {
    final box = Hive.box<MoodEntry>(AppConfig.moodBoxKey);
    await box.put(entry.id, entry);
    _entries.insert(0, entry);
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
    
    return _entries.firstWhere(
      (entry) => entry.timestamp.isAfter(today) && entry.timestamp.isBefore(tomorrow),
      orElse: () => MoodEntry(id: '', userId: '', moodLevel: 0),
    ).id.isEmpty
        ? null
        : _entries.first;
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
}
