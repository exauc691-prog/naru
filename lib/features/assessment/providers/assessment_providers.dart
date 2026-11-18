import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/assessment_store.dart';
import '../models/assessment_models.dart';

final assessmentStoreProvider = Provider<AssessmentStore>(
  (ref) => const AssessmentStore(),
);

final assessmentAttemptsProvider =
    AsyncNotifierProvider<AssessmentAttemptsNotifier,
        List<AssessmentAttempt>>(AssessmentAttemptsNotifier.new);

class AssessmentAttemptsNotifier
    extends AsyncNotifier<List<AssessmentAttempt>> {
  @override
  Future<List<AssessmentAttempt>> build() =>
      ref.read(assessmentStoreProvider).getAttempts();

  Future<AssessmentAttempt> save({
    required String assessmentId,
    required String assessmentTitle,
    required int score,
    required int total,
    required List<AssessmentAnswer> answers,
  }) async {
    final attempt = await ref.read(assessmentStoreProvider).saveAttempt(
          assessmentId: assessmentId,
          assessmentTitle: assessmentTitle,
          score: score,
          total: total,
          answers: answers,
        );
    state = AsyncData(await ref.read(assessmentStoreProvider).getAttempts());
    return attempt;
  }
}
