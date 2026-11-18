import 'model_json.dart';

class ModuleModel {
  ModuleModel({
    required this.id,
    required this.learningPathId,
    required this.title,
    required this.description,
    required this.order,
    required List<String> lessonIds,
    required this.isCompleted,
  }) : lessonIds = List.unmodifiable(lessonIds);

  final String id;
  final String learningPathId;
  final String title;
  final String description;
  final int order;
  final List<String> lessonIds;
  final bool isCompleted;

  factory ModuleModel.fromJson(ModelJsonMap json) => ModuleModel(
    id: ModelJson.requiredString(json, 'id'),
    learningPathId: ModelJson.requiredString(json, 'learningPathId'),
    title: ModelJson.requiredString(json, 'title'),
    description: ModelJson.requiredString(json, 'description'),
    order: ModelJson.requiredInt(json, 'order'),
    lessonIds: ModelJson.stringList(json, 'lessonIds'),
    isCompleted: ModelJson.requiredBool(json, 'isCompleted'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'learningPathId': learningPathId,
    'title': title,
    'description': description,
    'order': order,
    'lessonIds': lessonIds,
    'isCompleted': isCompleted,
  };
}
