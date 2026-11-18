typedef ModelJsonMap = Map<String, dynamic>;

abstract final class ModelJson {
  static String requiredString(ModelJsonMap json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    throw FormatException('Expected "$key" to be a string.');
  }

  static String? optionalString(ModelJsonMap json, String key) {
    final value = json[key];
    if (value == null || value is String) {
      return value as String?;
    }
    throw FormatException('Expected "$key" to be a string or null.');
  }

  static int requiredInt(ModelJsonMap json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    throw FormatException('Expected "$key" to be an integer.');
  }

  static int? optionalInt(ModelJsonMap json, String key) {
    final value = json[key];
    if (value == null || value is int) {
      return value as int?;
    }
    throw FormatException('Expected "$key" to be an integer or null.');
  }

  static double requiredDouble(ModelJsonMap json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    throw FormatException('Expected "$key" to be a number.');
  }

  static bool requiredBool(ModelJsonMap json, String key) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    throw FormatException('Expected "$key" to be a boolean.');
  }

  static bool? optionalBool(ModelJsonMap json, String key) {
    final value = json[key];
    if (value == null || value is bool) {
      return value as bool?;
    }
    throw FormatException('Expected "$key" to be a boolean or null.');
  }

  static DateTime requiredDateTime(ModelJsonMap json, String key) =>
      DateTime.parse(requiredString(json, key));

  static DateTime? optionalDateTime(ModelJsonMap json, String key) {
    final value = optionalString(json, key);
    return value == null ? null : DateTime.parse(value);
  }

  static Duration requiredDuration(ModelJsonMap json, String key) =>
      Duration(minutes: requiredInt(json, key));

  static List<String> stringList(ModelJsonMap json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Expected "$key" to be a list of strings.');
    }
    return List<String>.unmodifiable(
      value.asMap().entries.map((entry) {
        final item = entry.value;
        if (item is String) {
          return item;
        }
        throw FormatException('Expected "$key[${entry.key}]" to be a string.');
      }),
    );
  }

  static List<String> optionalStringList(ModelJsonMap json, String key) {
    if (json[key] == null) {
      return const [];
    }
    return stringList(json, key);
  }

  static T enumValue<T extends Enum>(
    List<T> values,
    Object? rawValue,
    String fieldName,
  ) {
    if (rawValue is String) {
      for (final value in values) {
        if (value.name == rawValue) {
          return value;
        }
      }
    }
    throw FormatException('Invalid value for "$fieldName": $rawValue.');
  }

  static List<T> enumList<T extends Enum>(
    List<T> values,
    ModelJsonMap json,
    String key,
  ) {
    final rawList = json[key];
    if (rawList is! List) {
      throw FormatException('Expected "$key" to be a list of enum values.');
    }
    return List<T>.unmodifiable(
      rawList.asMap().entries.map(
        (entry) => enumValue(values, entry.value, '$key[${entry.key}]'),
      ),
    );
  }

  static List<T> objectList<T>(
    ModelJsonMap json,
    String key,
    T Function(ModelJsonMap) fromJson,
  ) {
    final rawList = json[key];
    if (rawList is! List) {
      throw FormatException('Expected "$key" to be a list of objects.');
    }
    return List<T>.unmodifiable(
      rawList.asMap().entries.map(
        (entry) => fromJson(object(entry.value, '$key[${entry.key}]')),
      ),
    );
  }

  static ModelJsonMap object(Object? value, String fieldName) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('Expected "$fieldName" to be an object.');
  }
}
