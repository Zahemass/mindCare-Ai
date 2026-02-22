import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';

class JournalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  JournalProvider() {
    _loadEntries();
  }

  /// Load entries: first from local cache, then sync from backend
  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    // Load from local Hive first for instant data
    try {
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      _entries = box.values.toList();
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading local journals: $e');
    }

    // Then sync from backend
    await fetchFromBackend();

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch journal history from backend and update local cache
  Future<void> fetchFromBackend() async {
    try {
      final journalsData = await _apiService.getJournalHistory();
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);

      final backendEntries = journalsData.map((data) {
        return JournalEntry(
          id: data['id']?.toString() ?? '',
          userId: data['user_id']?.toString() ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : DateTime.now(),
        );
      }).toList();

      // Update local cache
      await box.clear();
      for (final entry in backendEntries) {
        await box.put(entry.id, entry);
      }

      _entries = backendEntries;
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _error = null;
    } catch (e) {
      debugPrint('Error fetching journals from backend: $e');
      _error = e.toString();
      // Keep using local data if backend fails
    }
    notifyListeners();
  }

  /// Add a journal entry - sends to backend and saves locally
  Future<void> addEntry(JournalEntry entry) async {
    try {
      // Send to backend first
      final response = await _apiService.createJournalEntry(
        title: entry.title,
        content: entry.content,
      );

      // Update entry with backend data
      final backendData = response['data'];
      final savedEntry = entry.copyWith(
        id: backendData?['id']?.toString() ?? entry.id,
      );

      // Save to local cache
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      await box.put(savedEntry.id, savedEntry);
      _entries.insert(0, savedEntry);
      _error = null;
    } catch (e) {
      debugPrint('Error saving journal to backend: $e');
      _error = e.toString();
      // Save locally anyway for offline support
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      await box.put(entry.id, entry);
      _entries.insert(0, entry);
    }
    notifyListeners();
  }

  /// Get AI insight for journal content
  Future<Map<String, dynamic>?> getAIInsight(String content) async {
    try {
      final response = await _apiService.getJournalAIInsight(content);
      return response; // { emotion, insight }
    } catch (e) {
      debugPrint('Error getting AI insight: $e');
      return null;
    }
  }

  Future<void> updateEntry(JournalEntry entry) async {
    try {
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      await box.put(entry.id, entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating journal: $e');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      await box.delete(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting journal: $e');
    }
  }

  JournalEntry? getEntryById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  bool get hasJournaledToday {
    if (_entries.isEmpty) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.any((entry) => entry.createdAt.isAfter(today));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
