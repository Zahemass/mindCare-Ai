class AssessmentQuestion {
  final String question;
  final int score;

  AssessmentQuestion({
    required this.question,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'score': score,
  };
}

class AssessmentResult {
  final String id;
  final String userId;
  final List<AssessmentQuestion> answers;
  final int score;
  final String riskLevel;
  final DateTime createdAt;

  AssessmentResult({
    required this.id,
    required this.userId,
    required this.answers,
    required this.score,
    required this.riskLevel,
    required this.createdAt,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      answers: (json['answers'] as List)
          .map((a) => AssessmentQuestion(
                question: a['question'],
                score: a['score'],
              ))
          .toList(),
      score: json['score'],
      riskLevel: json['risk_level'] ?? 'Low',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
