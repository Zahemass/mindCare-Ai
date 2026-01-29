import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 6)
class Goal extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  String category; // 'mental_health', 'meditation', 'journaling', 'mood', 'custom'
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime? targetDate;
  
  @HiveField(7)
  int targetValue; // e.g., 30 days of meditation
  
  @HiveField(8)
  int currentValue; // Current progress
  
  @HiveField(9)
  String unit; // 'days', 'sessions', 'entries', 'times'
  
  @HiveField(10)
  bool isCompleted;
  
  @HiveField(11)
  DateTime? completedAt;
  
  @HiveField(12)
  List<DateTime> milestones; // Track progress dates
  
  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    DateTime? createdAt,
    this.targetDate,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    this.isCompleted = false,
    this.completedAt,
    List<DateTime>? milestones,
  })  : createdAt = createdAt ?? DateTime.now(),
        milestones = milestones ?? [];
  
  // Get progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue * 100).clamp(0.0, 100.0);
  }
  
  // Check if goal is overdue
  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }
  
  // Get days remaining
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return 0;
    return targetDate!.difference(now).inDays;
  }
  
  // Increment progress
  void incrementProgress([int amount = 1]) {
    currentValue += amount;
    milestones.add(DateTime.now());
    
    if (currentValue >= targetValue && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }
  
  // Copy with method
  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? targetDate,
    int? targetValue,
    int? currentValue,
    String? unit,
    bool? isCompleted,
    DateTime? completedAt,
    List<DateTime>? milestones,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'milestones': milestones.map((m) => m.toIso8601String()).toList(),
    };
  }
  
  // From JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      targetValue: json['targetValue'],
      currentValue: json['currentValue'] ?? 0,
      unit: json['unit'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      milestones: (json['milestones'] as List?)
              ?.map((m) => DateTime.parse(m))
              .toList() ??
          [],
    );
  }
}
