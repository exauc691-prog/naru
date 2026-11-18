enum PersonalLearningLevel { beginner, intermediate, advanced, unknown }

enum PersonalPathStatus { notStarted, inProgress, paused, completed, archived }

class PersonalLearningGoal {
  const PersonalLearningGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.dailyMinutes,
    this.targetDate,
  });

  final String id;
  final String title;
  final String category;
  final PersonalLearningLevel level;
  final int dailyMinutes;
  final DateTime? targetDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'level': level.name,
    'dailyMinutes': dailyMinutes,
    'targetDate': targetDate?.toIso8601String(),
  };

  factory PersonalLearningGoal.fromJson(Map<String, dynamic> json) =>
      PersonalLearningGoal(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        level: PersonalLearningLevel.values.byName(json['level'] as String),
        dailyMinutes: json['dailyMinutes'] as int,
        targetDate: json['targetDate'] == null
            ? null
            : DateTime.parse(json['targetDate'] as String),
      );
}

class PersonalStudySession {
  const PersonalStudySession({
    required this.id,
    required this.day,
    required this.title,
    required this.durationMinutes,
    required this.isCompleted,
  });

  final String id;
  final String day;
  final String title;
  final int durationMinutes;
  final bool isCompleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'day': day,
    'title': title,
    'durationMinutes': durationMinutes,
    'isCompleted': isCompleted,
  };

  factory PersonalStudySession.fromJson(Map<String, dynamic> json) =>
      PersonalStudySession(
        id: json['id'] as String,
        day: json['day'] as String,
        title: json['title'] as String,
        durationMinutes: json['durationMinutes'] as int,
        isCompleted: json['isCompleted'] as bool,
      );
}
