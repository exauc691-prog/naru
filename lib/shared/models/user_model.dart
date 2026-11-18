import 'enums/difficulty_level.dart';
import 'model_json.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required List<String> selectedDomains,
    required this.currentLevel,
    required List<String> learningGoals,
    required this.dailyLearningMinutes,
    required this.joinedAt,
    required this.isOnboardingCompleted,
  }) : selectedDomains = List.unmodifiable(selectedDomains),
       learningGoals = List.unmodifiable(learningGoals);

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final List<String> selectedDomains;
  final DifficultyLevel currentLevel;
  final List<String> learningGoals;
  final int dailyLearningMinutes;
  final DateTime joinedAt;
  final bool isOnboardingCompleted;

  factory UserModel.fromJson(ModelJsonMap json) => UserModel(
    id: ModelJson.requiredString(json, 'id'),
    fullName: ModelJson.requiredString(json, 'fullName'),
    email: ModelJson.requiredString(json, 'email'),
    avatarUrl: ModelJson.optionalString(json, 'avatarUrl'),
    selectedDomains: ModelJson.stringList(json, 'selectedDomains'),
    currentLevel: ModelJson.enumValue(
      DifficultyLevel.values,
      json['currentLevel'],
      'currentLevel',
    ),
    learningGoals: ModelJson.stringList(json, 'learningGoals'),
    dailyLearningMinutes: ModelJson.requiredInt(json, 'dailyLearningMinutes'),
    joinedAt: ModelJson.requiredDateTime(json, 'joinedAt'),
    isOnboardingCompleted: ModelJson.requiredBool(
      json,
      'isOnboardingCompleted',
    ),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'avatarUrl': avatarUrl,
    'selectedDomains': selectedDomains,
    'currentLevel': currentLevel.name,
    'learningGoals': learningGoals,
    'dailyLearningMinutes': dailyLearningMinutes,
    'joinedAt': joinedAt.toIso8601String(),
    'isOnboardingCompleted': isOnboardingCompleted,
  };
}
