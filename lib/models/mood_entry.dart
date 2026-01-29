import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 1)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  int moodLevel; // 1-10 scale
  
  @HiveField(3)
  List<String> emotions;
  
  @HiveField(4)
  List<String> triggers;
  
  @HiveField(5)
  String? notes;
  
  @HiveField(6)
  DateTime timestamp;
  
  @HiveField(7)
  String? activities; // What were you doing?
  
  @HiveField(8)
  int? energyLevel; // 1-10 scale
  
  @HiveField(9)
  int? sleepQuality; // 1-10 scale (from previous night)
  
  @HiveField(10)
  int? stressLevel; // 0-100 scale

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodLevel,
    List<String>? emotions,
    List<String>? triggers,
    this.notes,
    DateTime? timestamp,
    this.activities,
    this.energyLevel,
    this.sleepQuality,
    this.stressLevel,
  })  : emotions = emotions ?? [],
        triggers = triggers ?? [],
        timestamp = timestamp ?? DateTime.now();
  
  // Get mood emoji based on level
  String get moodEmoji {
    const emojis = ['😢', '😞', '😕', '😐', '🙂', '😊', '😄', '😁', '🤗', '🥰'];
    return emojis[moodLevel - 1];
  }
  
  // Get mood label
  String get moodLabel {
    if (moodLevel <= 2) return 'Very Low';
    if (moodLevel <= 4) return 'Low';
    if (moodLevel <= 6) return 'Moderate';
    if (moodLevel <= 8) return 'Good';
    return 'Excellent';
  }
  
  // Copy with method
  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodLevel,
    List<String>? emotions,
    List<String>? triggers,
    String? notes,
    DateTime? timestamp,
    String? activities,
    int? energyLevel,
    int? sleepQuality,
    int? stressLevel,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodLevel: moodLevel ?? this.moodLevel,
      emotions: emotions ?? this.emotions,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      activities: activities ?? this.activities,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodLevel': moodLevel,
      'emotions': emotions,
      'triggers': triggers,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'activities': activities,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
    };
  }
  
  // From JSON
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      userId: json['userId'],
      moodLevel: json['moodLevel'],
      emotions: List<String>.from(json['emotions'] ?? []),
      triggers: List<String>.from(json['triggers'] ?? []),
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
      activities: json['activities'],
      energyLevel: json['energyLevel'],
      sleepQuality: json['sleepQuality'],
      stressLevel: json['stressLevel'],
    );
  }
}
