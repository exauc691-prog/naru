import 'enums/difficulty_level.dart';
import 'model_json.dart';

class LearningDomainModel {
  LearningDomainModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.imageUrl,
    required this.colorCode,
    required this.availableCoursesCount,
    required List<DifficultyLevel> difficultyLevels,
  }) : difficultyLevels = List.unmodifiable(difficultyLevels);

  final String id;
  final String name;
  final String description;
  final String icon;
  final String? imageUrl;
  final String colorCode;
  final int availableCoursesCount;
  final List<DifficultyLevel> difficultyLevels;

  factory LearningDomainModel.fromJson(ModelJsonMap json) =>
      LearningDomainModel(
        id: ModelJson.requiredString(json, 'id'),
        name: ModelJson.requiredString(json, 'name'),
        description: ModelJson.requiredString(json, 'description'),
        icon: ModelJson.requiredString(json, 'icon'),
        imageUrl: ModelJson.optionalString(json, 'imageUrl'),
        colorCode: ModelJson.requiredString(json, 'colorCode'),
        availableCoursesCount: ModelJson.requiredInt(
          json,
          'availableCoursesCount',
        ),
        difficultyLevels: ModelJson.enumList(
          DifficultyLevel.values,
          json,
          'difficultyLevels',
        ),
      );

  ModelJsonMap toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'imageUrl': imageUrl,
    'colorCode': colorCode,
    'availableCoursesCount': availableCoursesCount,
    'difficultyLevels': difficultyLevels.map((level) => level.name).toList(),
  };
}
