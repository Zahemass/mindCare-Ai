import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  int? age;

  @HiveField(4)
  String? gender;

  @HiveField(5)
  List<String> mentalHealthGoals;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime lastLoginAt;

  @HiveField(8)
  bool isPremium;

  @HiveField(9)
  DateTime? premiumExpiryDate;

  @HiveField(10)
  String? profileImageUrl;

  @HiveField(11)
  Map<String, dynamic> preferences;

  @HiveField(12)
  bool isAssessmentCompleted;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.age,
    this.gender,
    List<String>? mentalHealthGoals,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.profileImageUrl,
    Map<String, dynamic>? preferences,
    this.isAssessmentCompleted = false,
  })  : mentalHealthGoals = mentalHealthGoals ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now(),
        preferences = preferences ?? _defaultPreferences();

  static Map<String, dynamic> _defaultPreferences() {
    return {
      'theme': 'system',
      'notificationsEnabled': true,
      'moodReminderTime': '20:00',
      'meditationReminderTime': '08:00',
      'moodReminderEnabled': true,
      'meditationReminderEnabled': true,
      'soundEnabled': true,
      'hapticFeedbackEnabled': true,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? gender,
    List<String>? mentalHealthGoals,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    bool? isAssessmentCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      mentalHealthGoals: mentalHealthGoals ?? this.mentalHealthGoals,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      isAssessmentCompleted:
      isAssessmentCompleted ?? this.isAssessmentCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'mentalHealthGoals': mentalHealthGoals,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'isAssessmentCompleted': isAssessmentCompleted,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      mentalHealthGoals:
      List<String>.from(json['mentalHealthGoals'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      preferences:
      Map<String, dynamic>.from(json['preferences'] ?? {}),
      isAssessmentCompleted:
      json['isAssessmentCompleted'] ?? false,
    );
  }
}
