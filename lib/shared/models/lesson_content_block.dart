import 'enums/lesson_content_type.dart';
import 'model_json.dart';

sealed class LessonContentBlock {
  const LessonContentBlock();

  LessonContentType get type;

  factory LessonContentBlock.fromJson(ModelJsonMap json) {
    final type = ModelJson.enumValue(
      LessonContentType.values,
      json['type'],
      'type',
    );

    return switch (type) {
      LessonContentType.paragraph => LessonParagraphBlock(
        text: ModelJson.requiredString(json, 'text'),
      ),
      LessonContentType.heading => LessonHeadingBlock(
        text: ModelJson.requiredString(json, 'text'),
        level: ModelJson.requiredInt(json, 'level'),
      ),
      LessonContentType.list => LessonListBlock(
        items: ModelJson.stringList(json, 'items'),
        ordered: ModelJson.requiredBool(json, 'ordered'),
      ),
      LessonContentType.code => LessonCodeBlock(
        code: ModelJson.requiredString(json, 'code'),
        language: ModelJson.optionalString(json, 'language'),
      ),
      LessonContentType.example => LessonExampleBlock(
        title: ModelJson.requiredString(json, 'title'),
        content: ModelJson.objectList(
          json,
          'content',
          LessonContentBlock.fromJson,
        ),
      ),
      LessonContentType.image => LessonImageBlock(
        url: ModelJson.requiredString(json, 'url'),
        altText: ModelJson.requiredString(json, 'altText'),
        caption: ModelJson.optionalString(json, 'caption'),
      ),
      LessonContentType.importantPoint => LessonImportantPointBlock(
        text: ModelJson.requiredString(json, 'text'),
      ),
    };
  }

  ModelJsonMap toJson();
}

class LessonParagraphBlock extends LessonContentBlock {
  const LessonParagraphBlock({required this.text});

  final String text;

  @override
  LessonContentType get type => LessonContentType.paragraph;

  @override
  ModelJsonMap toJson() => {'type': type.name, 'text': text};
}

class LessonHeadingBlock extends LessonContentBlock {
  const LessonHeadingBlock({required this.text, required this.level})
    : assert(level >= 1 && level <= 6);

  final String text;
  final int level;

  @override
  LessonContentType get type => LessonContentType.heading;

  @override
  ModelJsonMap toJson() => {'type': type.name, 'text': text, 'level': level};
}

class LessonListBlock extends LessonContentBlock {
  LessonListBlock({required List<String> items, required this.ordered})
    : items = List.unmodifiable(items);

  final List<String> items;
  final bool ordered;

  @override
  LessonContentType get type => LessonContentType.list;

  @override
  ModelJsonMap toJson() => {
    'type': type.name,
    'items': items,
    'ordered': ordered,
  };
}

class LessonCodeBlock extends LessonContentBlock {
  const LessonCodeBlock({required this.code, this.language});

  final String code;
  final String? language;

  @override
  LessonContentType get type => LessonContentType.code;

  @override
  ModelJsonMap toJson() => {
    'type': type.name,
    'code': code,
    'language': language,
  };
}

class LessonExampleBlock extends LessonContentBlock {
  LessonExampleBlock({
    required this.title,
    required List<LessonContentBlock> content,
  }) : content = List.unmodifiable(content);

  final String title;
  final List<LessonContentBlock> content;

  @override
  LessonContentType get type => LessonContentType.example;

  @override
  ModelJsonMap toJson() => {
    'type': type.name,
    'title': title,
    'content': content.map((block) => block.toJson()).toList(),
  };
}

class LessonImageBlock extends LessonContentBlock {
  const LessonImageBlock({
    required this.url,
    required this.altText,
    this.caption,
  });

  final String url;
  final String altText;
  final String? caption;

  @override
  LessonContentType get type => LessonContentType.image;

  @override
  ModelJsonMap toJson() => {
    'type': type.name,
    'url': url,
    'altText': altText,
    'caption': caption,
  };
}

class LessonImportantPointBlock extends LessonContentBlock {
  const LessonImportantPointBlock({required this.text});

  final String text;

  @override
  LessonContentType get type => LessonContentType.importantPoint;

  @override
  ModelJsonMap toJson() => {'type': type.name, 'text': text};
}
