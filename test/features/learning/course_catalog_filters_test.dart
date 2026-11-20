import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/learning/data/course_catalog_filters.dart';
import 'package:naru/shared/mock/mock_courses.dart';
import 'package:naru/shared/models/enums/course_format.dart';
import 'package:naru/shared/models/enums/difficulty_level.dart';

void main() {
  test('combines course type, format and level filters', () {
    const filters = CourseCatalogFilters(
      level: DifficultyLevel.beginner,
      isPremium: true,
      format: CourseFormat.video,
    );

    final results = mockCourses.where(filters.matches);

    expect(results.map((course) => course.id), [
      'javascript-basics',
      'flutter-introduction',
      'sql-for-beginners',
    ]);
    expect(filters.activeCount, 3);
    expect(filters.labels, ['Débutant', 'Premium', 'Vidéo']);
  });

  test('duration ranges have clear boundaries', () {
    expect(
      CourseDurationRange.underTwoHours.includes(const Duration(minutes: 119)),
      isTrue,
    );
    expect(
      CourseDurationRange.underTwoHours.includes(const Duration(hours: 2)),
      isFalse,
    );
    expect(
      CourseDurationRange.twoToFiveHours.includes(const Duration(hours: 5)),
      isTrue,
    );
    expect(
      CourseDurationRange.fiveToTenHours.includes(const Duration(hours: 5)),
      isFalse,
    );
    expect(
      CourseDurationRange.overTenHours.includes(const Duration(hours: 10)),
      isFalse,
    );
    expect(
      CourseDurationRange.overTenHours.includes(
        const Duration(hours: 10, minutes: 1),
      ),
      isTrue,
    );
  });
}
