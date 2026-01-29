import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 2)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String content;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime updatedAt;
  
  @HiveField(6)
  int? moodLevel; // Optional mood tag
  
  @HiveField(7)
  List<String> tags;
  
  @HiveField(8)
  double? sentimentScore; // -1.0 to 1.0
  
  @HiveField(9)
  List<String> detectedEmotions;
  
  @HiveField(10)
  String? aiInsight;
  
  @HiveField(11)
  bool isFavorite;
  
  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.moodLevel,
    List<String>? tags,
    this.sentimentScore,
    List<String>? detectedEmotions,
    this.aiInsight,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        detectedEmotions = detectedEmotions ?? [];
  
  // Get sentiment label
  String get sentimentLabel {
    if (sentimentScore == null) return 'Unknown';
    if (sentimentScore! >= 0.5) return 'Very Positive';
    if (sentimentScore! >= 0.2) return 'Positive';
    if (sentimentScore! >= -0.2) return 'Neutral';
    if (sentimentScore! >= -0.5) return 'Negative';
    return 'Very Negative';
  }
  
  // Get sentiment emoji
  String get sentimentEmoji {
    if (sentimentScore == null) return '😐';
    if (sentimentScore! >= 0.5) return '😊';
    if (sentimentScore! >= 0.2) return '🙂';
    if (sentimentScore! >= -0.2) return '😐';
    if (sentimentScore! >= -0.5) return '😕';
    return '😢';
  }
  
  // Copy with method
  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? moodLevel,
    List<String>? tags,
    double? sentimentScore,
    List<String>? detectedEmotions,
    String? aiInsight,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodLevel: moodLevel ?? this.moodLevel,
      tags: tags ?? this.tags,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      detectedEmotions: detectedEmotions ?? this.detectedEmotions,
      aiInsight: aiInsight ?? this.aiInsight,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'moodLevel': moodLevel,
      'tags': tags,
      'sentimentScore': sentimentScore,
      'detectedEmotions': detectedEmotions,
      'aiInsight': aiInsight,
      'isFavorite': isFavorite,
    };
  }
  
  // From JSON
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      moodLevel: json['moodLevel'],
      tags: List<String>.from(json['tags'] ?? []),
      sentimentScore: json['sentimentScore']?.toDouble(),
      detectedEmotions: List<String>.from(json['detectedEmotions'] ?? []),
      aiInsight: json['aiInsight'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
