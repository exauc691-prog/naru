import '../../../shared/models/enums/difficulty_level.dart';

String difficultyLabel(DifficultyLevel level) => switch (level) {
  DifficultyLevel.beginner => 'Débutant',
  DifficultyLevel.intermediate => 'Intermédiaire',
  DifficultyLevel.advanced => 'Avancé',
};

String durationLabel(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours == 0) return '$minutes min';
  return minutes == 0 ? '$hours h' : '$hours h $minutes min';
}

String learnerCountLabel(int count) {
  if (count < 1000) return '$count apprenants';
  return '${(count / 1000).toStringAsFixed(1)} k apprenants';
}
