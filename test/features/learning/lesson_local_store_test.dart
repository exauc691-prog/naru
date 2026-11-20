import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/learning/data/lesson_local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'persists notes, favorites, bookmarks, completion, and history',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = LessonLocalStore();

      await store.saveNote('lesson-1', 'Revoir les exemples');
      await store.setFavorite('lesson-1', true);
      await store.toggleBookmark('lesson-1', 'Les variables');
      await store.setCompleted('lesson-1');
      await store.recordOpened('lesson-1');

      final lesson = await store.load('lesson-1');
      final history = await store.loadHistory();
      expect(lesson.note, 'Revoir les exemples');
      expect(lesson.isFavorite, isTrue);
      expect(lesson.bookmarks, ['Les variables']);
      expect(lesson.isCompleted, isTrue);
      expect(await store.loadCompletedLessonIds(), contains('lesson-1'));
      expect(DateTime.tryParse(history['lesson-1']!), isNotNull);

      await store.saveNote('lesson-1', '  ');
      await store.setFavorite('lesson-1', false);
      await store.toggleBookmark('lesson-1', 'Les variables');
      final clearedLesson = await store.load('lesson-1');
      expect(clearedLesson.note, isEmpty);
      expect(clearedLesson.isFavorite, isFalse);
      expect(clearedLesson.bookmarks, isEmpty);
    },
  );
}
