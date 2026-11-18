import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/course_format.dart';
import '../../../shared/models/enums/difficulty_level.dart';

enum CourseDurationRange {
  underTwoHours('Moins de 2 heures'),
  twoToFiveHours('2 à 5 heures'),
  fiveToTenHours('5 à 10 heures'),
  overTenHours('Plus de 10 heures');

  const CourseDurationRange(this.label);

  final String label;

  bool includes(Duration duration) => switch (this) {
    CourseDurationRange.underTwoHours => duration < const Duration(hours: 2),
    CourseDurationRange.twoToFiveHours =>
      duration >= const Duration(hours: 2) &&
          duration <= const Duration(hours: 5),
    CourseDurationRange.fiveToTenHours =>
      duration > const Duration(hours: 5) &&
          duration <= const Duration(hours: 10),
    CourseDurationRange.overTenHours => duration > const Duration(hours: 10),
  };
}

class CourseCatalogFilters {
  const CourseCatalogFilters({
    this.level,
    this.duration,
    this.isPremium,
    this.format,
  });

  final DifficultyLevel? level;
  final CourseDurationRange? duration;
  final bool? isPremium;
  final CourseFormat? format;

  bool get isEmpty =>
      level == null && duration == null && isPremium == null && format == null;

  int get activeCount => [
    level,
    duration,
    isPremium,
    format,
  ].where((value) => value != null).length;

  List<String> get labels => [
    if (level case final value?)
      switch (value) {
        DifficultyLevel.beginner => 'Débutant',
        DifficultyLevel.intermediate => 'Intermédiaire',
        DifficultyLevel.advanced => 'Avancé',
      },
    if (duration case final value?) value.label,
    if (isPremium != null) isPremium! ? 'Premium' : 'Gratuit',
    if (format case final value?) value.label,
  ];

  bool matches(CourseModel course) =>
      (level == null || course.difficulty == level) &&
      (duration == null || duration!.includes(course.estimatedDuration)) &&
      (isPremium == null || course.isPremium == isPremium) &&
      (format == null || course.format == format);
}
