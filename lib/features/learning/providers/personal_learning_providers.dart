import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/personal_learning_store.dart';
import '../models/personal_learning_models.dart';

final personalLearningStoreProvider = Provider<PersonalLearningStore>(
  (ref) => const PersonalLearningStore(),
);

final personalLearningGoalsProvider =
    AsyncNotifierProvider<PersonalLearningGoalsNotifier,
        List<PersonalLearningGoal>>(PersonalLearningGoalsNotifier.new);

class PersonalLearningGoalsNotifier
    extends AsyncNotifier<List<PersonalLearningGoal>> {
  @override
  Future<List<PersonalLearningGoal>> build() =>
      ref.read(personalLearningStoreProvider).getGoals();

  Future<void> save(PersonalLearningGoal goal) async {
    await ref.read(personalLearningStoreProvider).saveGoal(goal);
    state = AsyncData(await ref.read(personalLearningStoreProvider).getGoals());
  }

  Future<void> delete(String id) async {
    await ref.read(personalLearningStoreProvider).deleteGoal(id);
    state = AsyncData(await ref.read(personalLearningStoreProvider).getGoals());
  }
}

final studySessionsProvider =
    AsyncNotifierProvider<StudySessionsNotifier, List<PersonalStudySession>>(
      StudySessionsNotifier.new,
    );

class StudySessionsNotifier
    extends AsyncNotifier<List<PersonalStudySession>> {
  @override
  Future<List<PersonalStudySession>> build() =>
      ref.read(personalLearningStoreProvider).getSessions();

  Future<void> toggle(String id) async {
    await ref.read(personalLearningStoreProvider).toggleSession(id);
    state = AsyncData(await ref.read(personalLearningStoreProvider).getSessions());
  }
}
