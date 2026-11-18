import '../../../shared/models/model_json.dart';

class AssistantVoiceEntry {
  const AssistantVoiceEntry({
    required this.id,
    required this.exampleText,
    required this.createdAt,
  });

  final String id;
  final String exampleText;
  final DateTime createdAt;

  factory AssistantVoiceEntry.fromJson(ModelJsonMap json) =>
      AssistantVoiceEntry(
        id: ModelJson.requiredString(json, 'id'),
        exampleText: ModelJson.requiredString(json, 'exampleText'),
        createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
      );

  ModelJsonMap toJson() => {
    'id': id,
    'exampleText': exampleText,
    'createdAt': createdAt.toIso8601String(),
  };
}
