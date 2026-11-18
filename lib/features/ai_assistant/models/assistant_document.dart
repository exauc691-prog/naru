import '../../../shared/models/model_json.dart';

class AssistantDocument {
  const AssistantDocument({
    required this.id,
    required this.name,
    required this.format,
    required this.sizeLabel,
    required this.addedAt,
  });

  final String id;
  final String name;
  final String format;
  final String sizeLabel;
  final DateTime addedAt;

  factory AssistantDocument.fromJson(ModelJsonMap json) => AssistantDocument(
    id: ModelJson.requiredString(json, 'id'),
    name: ModelJson.requiredString(json, 'name'),
    format: ModelJson.requiredString(json, 'format'),
    sizeLabel: ModelJson.requiredString(json, 'sizeLabel'),
    addedAt: ModelJson.requiredDateTime(json, 'addedAt'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'name': name,
    'format': format,
    'sizeLabel': sizeLabel,
    'addedAt': addedAt.toIso8601String(),
  };
}
