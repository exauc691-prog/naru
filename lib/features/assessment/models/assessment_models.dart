class AssessmentAnswer {
  const AssessmentAnswer({
    required this.questionId,
    required this.answer,
    required this.isCorrect,
  });

  final String questionId;
  final String answer;
  final bool isCorrect;

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answer': answer,
    'isCorrect': isCorrect,
  };

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) =>
      AssessmentAnswer(
        questionId: json['questionId'] as String,
        answer: json['answer'] as String,
        isCorrect: json['isCorrect'] as bool,
      );
}

class AssessmentAttempt {
  const AssessmentAttempt({
    required this.id,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.score,
    required this.total,
    required this.answers,
    required this.completedAt,
    required this.attemptNumber,
  });

  final String id;
  final String assessmentId;
  final String assessmentTitle;
  final int score;
  final int total;
  final List<AssessmentAnswer> answers;
  final DateTime completedAt;
  final int attemptNumber;

  int get percentage =>
      total == 0 ? 0 : ((score / total) * 100).round();

  Map<String, dynamic> toJson() => {
    'id': id,
    'assessmentId': assessmentId,
    'assessmentTitle': assessmentTitle,
    'score': score,
    'total': total,
    'answers': answers.map((answer) => answer.toJson()).toList(),
    'completedAt': completedAt.toIso8601String(),
    'attemptNumber': attemptNumber,
  };

  factory AssessmentAttempt.fromJson(Map<String, dynamic> json) =>
      AssessmentAttempt(
        id: json['id'] as String,
        assessmentId: json['assessmentId'] as String,
        assessmentTitle: json['assessmentTitle'] as String,
        score: json['score'] as int,
        total: json['total'] as int,
        answers: [
          for (final answer in json['answers'] as List)
            AssessmentAnswer.fromJson(
              Map<String, dynamic>.from(answer as Map),
            ),
        ],
        completedAt: DateTime.parse(json['completedAt'] as String),
        attemptNumber: json['attemptNumber'] as int,
      );
}

class CompetencyProgress {
  const CompetencyProgress({
    required this.id,
    required this.name,
    required this.category,
    required this.progress,
  });

  final String id;
  final String name;
  final String category;
  final int progress;
}
