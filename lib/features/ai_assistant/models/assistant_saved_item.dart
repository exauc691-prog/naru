import '../../../shared/models/model_json.dart';

class AssistantSavedItem {
  const AssistantSavedItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;

  factory AssistantSavedItem.fromJson(ModelJsonMap json) =>
      AssistantSavedItem(
        id: ModelJson.requiredString(json, 'id'),
        title: ModelJson.requiredString(json, 'title'),
        content: ModelJson.requiredString(json, 'content'),
        category: ModelJson.requiredString(json, 'category'),
        createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
      );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };
}
