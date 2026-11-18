import '../../../shared/models/model_json.dart';

class LibraryCollection {
  LibraryCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required List<String> resourceIds,
  }) : resourceIds = List.unmodifiable(resourceIds);

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> resourceIds;

  factory LibraryCollection.fromJson(ModelJsonMap json) => LibraryCollection(
    id: ModelJson.requiredString(json, 'id'),
    name: ModelJson.requiredString(json, 'name'),
    createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
    updatedAt: ModelJson.requiredDateTime(json, 'updatedAt'),
    resourceIds: ModelJson.stringList(json, 'resourceIds'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'resourceIds': resourceIds,
  };
}
