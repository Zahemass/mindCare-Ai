import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 5)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  bool isUser; // true if message from user, false if from AI
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  bool isCrisisDetected;
  
  @HiveField(6)
  int? crisisSeverity; // 0-3
  
  @HiveField(7)
  List<String> suggestedActions;
  
  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isCrisisDetected = false,
    this.crisisSeverity,
    List<String>? suggestedActions,
  })  : timestamp = timestamp ?? DateTime.now(),
        suggestedActions = suggestedActions ?? [];
  
  // Copy with method
  ChatMessage copyWith({
    String? id,
    String? userId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isCrisisDetected,
    int? crisisSeverity,
    List<String>? suggestedActions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isCrisisDetected: isCrisisDetected ?? this.isCrisisDetected,
      crisisSeverity: crisisSeverity ?? this.crisisSeverity,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isCrisisDetected': isCrisisDetected,
      'crisisSeverity': crisisSeverity,
      'suggestedActions': suggestedActions,
    };
  }
  
  // From JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      isCrisisDetected: json['isCrisisDetected'] ?? false,
      crisisSeverity: json['crisisSeverity'],
      suggestedActions: List<String>.from(json['suggestedActions'] ?? []),
    );
  }
}
