import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';
import '../config/app_config.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  JournalProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      _entries = box.values.toList();
      _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading journals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    try {
      final box = Hive.box<JournalEntry>(AppConfig.journalBoxKey);
      await box.put(entry.id, entry);
      _entries.insert(0, entry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding journal: $e');
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
}
