import 'package:hive/hive.dart';

part 'meditation_session.g.dart';

@HiveType(typeId: 3)
class MeditationSession extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  int durationMinutes;
  
  @HiveField(4)
  String category; // 'anxiety', 'sleep', 'stress', 'mindfulness', 'breathing'
  
  @HiveField(5)
  String? audioUrl; // Local or remote audio file
  
  @HiveField(6)
  String? script; // Text script for the meditation
  
  @HiveField(7)
  String? imageUrl;
  
  @HiveField(8)
  bool isPremium;
  
  @HiveField(9)
  List<String> tags;
  
  @HiveField(10)
  String? instructor;
  
  MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    this.audioUrl,
    this.script,
    this.imageUrl,
    this.isPremium = false,
    List<String>? tags,
    this.instructor,
  }) : tags = tags ?? [];
  
  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'anxiety':
        return '🧘';
      case 'sleep':
        return '😴';
      case 'stress':
        return '🌊';
      case 'mindfulness':
        return '🧠';
      case 'breathing':
        return '💨';
      default:
        return '🧘';
    }
  }
  
  // Get category color (as hex string)
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'anxiety':
        return '#9B59B6';
      case 'sleep':
        return '#3498DB';
      case 'stress':
        return '#1ABC9C';
      case 'mindfulness':
        return '#E67E22';
      case 'breathing':
        return '#2ECC71';
      default:
        return '#95A5A6';
    }
  }
  
  // Copy with method
  MeditationSession copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    String? category,
    String? audioUrl,
    String? script,
    String? imageUrl,
    bool? isPremium,
    List<String>? tags,
    String? instructor,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      audioUrl: audioUrl ?? this.audioUrl,
      script: script ?? this.script,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      instructor: instructor ?? this.instructor,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'category': category,
      'audioUrl': audioUrl,
      'script': script,
      'imageUrl': imageUrl,
      'isPremium': isPremium,
      'tags': tags,
      'instructor': instructor,
    };
  }
  
  // From JSON
  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      category: json['category'],
      audioUrl: json['audioUrl'],
      script: json['script'],
      imageUrl: json['imageUrl'],
      isPremium: json['isPremium'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      instructor: json['instructor'],
    );
  }
}

@HiveType(typeId: 4)
class MeditationHistory extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String sessionId;
  
  @HiveField(3)
  DateTime completedAt;
  
  @HiveField(4)
  int durationMinutes;
  
  @HiveField(5)
  bool completed; // Did they complete the full session?
  
  @HiveField(6)
  int? rating; // 1-5 stars
  
  MeditationHistory({
    required this.id,
    required this.userId,
    required this.sessionId,
    DateTime? completedAt,
    required this.durationMinutes,
    this.completed = true,
    this.rating,
  }) : completedAt = completedAt ?? DateTime.now();
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'completedAt': completedAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed,
      'rating': rating,
    };
  }
  
  // From JSON
  factory MeditationHistory.fromJson(Map<String, dynamic> json) {
    return MeditationHistory(
      id: json['id'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      completedAt: DateTime.parse(json['completedAt']),
      durationMinutes: json['durationMinutes'],
      completed: json['completed'] ?? true,
      rating: json['rating'],
    );
  }
}
