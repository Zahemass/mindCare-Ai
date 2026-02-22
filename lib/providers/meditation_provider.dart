import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../models/meditation_session.dart';

class MeditationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<MeditationSession> _sessions = [];
  bool _isLoading = false;
  String? _error;
  
  MeditationSession? _currentSession;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _todayCompletedCount = 0;

  List<MeditationSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  MeditationSession? get currentSession => _currentSession;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get totalDuration => _duration;
  int get todayCompletedCount => _todayCompletedCount;
  bool get hasCompletedMeditationToday => _todayCompletedCount > 0;

  MeditationProvider() {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (_currentSession != null) {
          completeSession(_currentSession!.id, _duration.inSeconds);
        }
        _isPlaying = false;
        _currentSession = null;
      }
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> fetchSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessionsData = await _apiService.getMeditationSessions();
      _sessions = sessionsData.map((data) => MeditationSession.fromJson(data)).toList();
      await fetchActivityInsights();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActivityInsights() async {
    try {
      final response = await _apiService.getActivityInsights();
      final activities = response['activities'] as List<dynamic>?;
      if (activities != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        _todayCompletedCount = activities.where((a) {
          final completedAt = DateTime.parse(a['completed_at']);
          return completedAt.isAfter(today);
        }).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching activity insights: $e');
    }
  }

  Future<void> playSession(MeditationSession session) async {
    if (session.audioUrl == null) return;

    try {
      if (_currentSession?.id == session.id) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        await _audioPlayer.stop();
        _currentSession = session;
        await _audioPlayer.setUrl(session.audioUrl!);
        await _audioPlayer.play();
      }
    } catch (e) {
      _error = "Error playing audio: $e";
      notifyListeners();
    }
  }

  Future<void> pauseSession() async {
    await _audioPlayer.pause();
  }

  Future<void> stopSession() async {
    await _audioPlayer.stop();
    _currentSession = null;
    notifyListeners();
  }

  Future<void> seek(Duration pos) async {
    await _audioPlayer.seek(pos);
  }

  Future<bool> completeSession(String sessionId, int duration) async {
    try {
      await _apiService.completeActivity(
        activityId: sessionId,
        duration: duration,
      );
      _todayCompletedCount++;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<MeditationSession> getSessionsByCategory(String category) {
    if (category.toLowerCase() == 'all') return _sessions;
    return _sessions.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
