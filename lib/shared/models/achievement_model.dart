import 'enums/achievement_category.dart';
import 'model_json.dart';

class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.unlockedAt,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  factory AchievementModel.fromJson(ModelJsonMap json) => AchievementModel(
    id: ModelJson.requiredString(json, 'id'),
    title: ModelJson.requiredString(json, 'title'),
    description: ModelJson.requiredString(json, 'description'),
    icon: ModelJson.requiredString(json, 'icon'),
    category: ModelJson.enumValue(
      AchievementCategory.values,
      json['category'],
      'category',
    ),
    unlockedAt: ModelJson.optionalDateTime(json, 'unlockedAt'),
    isUnlocked: ModelJson.requiredBool(json, 'isUnlocked'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'category': category.name,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'isUnlocked': isUnlocked,
  };
}
