class Resource {
  String id;
  String title;
  String description;
  String category; // 'anxiety', 'depression', 'stress', 'sleep', 'relationships', 'coping'
  String type; // 'article', 'video', 'audio', 'exercise'
  String content; // Markdown content for articles
  String? mediaUrl; // URL for video/audio
  String? thumbnailUrl;
  List<String> tags;
  int readTimeMinutes;
  bool isPremium;
  DateTime createdAt;
  
  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    List<String>? tags,
    this.readTimeMinutes = 5,
    this.isPremium = false,
    DateTime? createdAt,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();
  
  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'anxiety':
        return '😰';
      case 'depression':
        return '😔';
      case 'stress':
        return '😫';
      case 'sleep':
        return '😴';
      case 'relationships':
        return '❤️';
      case 'coping':
        return '💪';
      default:
        return '📚';
    }
  }
  
  // Get type icon
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'article':
        return '📄';
      case 'video':
        return '🎥';
      case 'audio':
        return '🎧';
      case 'exercise':
        return '🏃';
      default:
        return '📚';
    }
  }
  
  // Copy with method
  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    List<String>? tags,
    int? readTimeMinutes,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'readTimeMinutes': readTimeMinutes,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // From JSON
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: (json['id'] ?? json['_id']).toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? json['summary'] ?? '',
      category: json['category'] ?? 'General',
      type: json['type'] ?? 'article',
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'] ?? json['media_url'] ?? json['external_url'] ?? json['url'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail_url'],
      tags: List<String>.from(json['tags'] ?? []),
      readTimeMinutes: json['readTimeMinutes'] ?? json['read_time'] ?? 5,
      isPremium: json['isPremium'] ?? json['is_premium'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
