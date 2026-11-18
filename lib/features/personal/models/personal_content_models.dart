class PersonalNote {
  PersonalNote({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'source': source,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PersonalNote.fromJson(Map<String, dynamic> json) => PersonalNote(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    source: json['source'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class PersonalBookmark {
  const PersonalBookmark({
    required this.id,
    required this.title,
    required this.source,
    required this.location,
    required this.excerpt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String source;
  final String location;
  final String excerpt;
  final DateTime createdAt;
}
