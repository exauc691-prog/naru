import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/assessment_models.dart';

class AssessmentStore {
  const AssessmentStore();

  static const _attemptsKey = 'naru.assessment.attempts.v1';

  Future<List<AssessmentAttempt>> getAttempts() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_attemptsKey) ?? const [];
    return [
      for (final value in values)
        AssessmentAttempt.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        ),
    ]..sort((left, right) =>
        right.completedAt.compareTo(left.completedAt));
  }

  Future<AssessmentAttempt> saveAttempt({
    required String assessmentId,
    required String assessmentTitle,
    required int score,
    required int total,
    required List<AssessmentAnswer> answers,
  }) async {
    final attempts = await getAttempts();
    final attemptNumber = attempts
            .where((attempt) => attempt.assessmentId == assessmentId)
            .length +
        1;
    final now = DateTime.now();
    final attempt = AssessmentAttempt(
      id: 'attempt-${now.microsecondsSinceEpoch}',
      assessmentId: assessmentId,
      assessmentTitle: assessmentTitle,
      score: score,
      total: total,
      answers: answers,
      completedAt: now,
      attemptNumber: attemptNumber,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _attemptsKey,
      [jsonEncode(attempt.toJson()), ...attempts.map((item) => jsonEncode(item.toJson()))],
    );
    return attempt;
  }
}
