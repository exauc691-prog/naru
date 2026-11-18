import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lesson_local_store.dart';

final lessonLocalStoreProvider = Provider<LessonLocalStore>(
  (ref) => LessonLocalStore(),
);

final lessonLocalDataProvider = FutureProvider.family<LessonLocalData, String>(
  (ref, lessonId) => ref.watch(lessonLocalStoreProvider).load(lessonId),
);

final completedLessonIdsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(lessonLocalStoreProvider).loadCompletedLessonIds(),
);

final lessonHistoryProvider = FutureProvider<Map<String, String>>(
  (ref) => ref.watch(lessonLocalStoreProvider).loadHistory(),
);
