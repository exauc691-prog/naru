import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LessonLocalData {
  const LessonLocalData({
    required this.note,
    required this.isFavorite,
    required this.bookmarks,
    required this.isCompleted,
  });

  final String note;
  final bool isFavorite;
  final List<String> bookmarks;
  final bool isCompleted;
}

class LessonLocalStore {
  static const _completedKey = 'naru.learning.completed_lessons';
  static const _favoritesKey = 'naru.learning.favorite_lessons';
  static const _notesKey = 'naru.learning.lesson_notes';
  static const _bookmarksKey = 'naru.learning.lesson_bookmarks';
  static const _historyKey = 'naru.learning.lesson_history';

  Future<LessonLocalData> load(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final notes = _readStringMap(preferences.getString(_notesKey), _notesKey);
    final bookmarks = _readListMap(
      preferences.getString(_bookmarksKey),
      _bookmarksKey,
    );
    return LessonLocalData(
      note: notes[lessonId] ?? '',
      isFavorite:
          preferences.getStringList(_favoritesKey)?.contains(lessonId) ?? false,
      bookmarks: List.unmodifiable(bookmarks[lessonId] ?? const []),
      isCompleted:
          preferences.getStringList(_completedKey)?.contains(lessonId) ?? false,
    );
  }

  Future<Set<String>> loadCompletedLessonIds() async {
    final preferences = await SharedPreferences.getInstance();
    return Set.unmodifiable(
      preferences.getStringList(_completedKey) ?? const <String>[],
    );
  }

  Future<void> recordOpened(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final history = _readStringMap(
      preferences.getString(_historyKey),
      _historyKey,
    );
    history[lessonId] = DateTime.now().toIso8601String();
    await _writeStringMap(preferences, _historyKey, history);
  }

  Future<void> saveNote(String lessonId, String note) async {
    final preferences = await SharedPreferences.getInstance();
    final notes = _readStringMap(preferences.getString(_notesKey), _notesKey);
    final normalizedNote = note.trim();
    if (normalizedNote.isEmpty) {
      notes.remove(lessonId);
    } else {
      notes[lessonId] = normalizedNote;
    }
    await _writeStringMap(preferences, _notesKey, notes);
  }

  Future<void> setFavorite(String lessonId, bool isFavorite) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = preferences.getStringList(_favoritesKey)?.toSet() ?? {};
    if (isFavorite) {
      favorites.add(lessonId);
    } else {
      favorites.remove(lessonId);
    }
    final saved = await preferences.setStringList(
      _favoritesKey,
      favorites.toList()..sort(),
    );
    if (!saved) throw StateError('Unable to persist lesson favorites.');
  }

  Future<void> setCompleted(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final completed = preferences.getStringList(_completedKey)?.toSet() ?? {};
    completed.add(lessonId);
    final saved = await preferences.setStringList(
      _completedKey,
      completed.toList()..sort(),
    );
    if (!saved) throw StateError('Unable to persist lesson progress.');
  }

  Future<void> toggleBookmark(String lessonId, String sectionTitle) async {
    final preferences = await SharedPreferences.getInstance();
    final bookmarks = _readListMap(
      preferences.getString(_bookmarksKey),
      _bookmarksKey,
    );
    final sections = bookmarks[lessonId] ?? <String>[];
    if (!sections.remove(sectionTitle)) sections.add(sectionTitle);
    sections.sort();
    if (sections.isEmpty) {
      bookmarks.remove(lessonId);
    } else {
      bookmarks[lessonId] = sections;
    }
    await _writeListMap(preferences, _bookmarksKey, bookmarks);
  }

  Future<Map<String, String>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    return Map.unmodifiable(
      _readStringMap(preferences.getString(_historyKey), _historyKey),
    );
  }

  Future<void> _writeStringMap(
    SharedPreferences preferences,
    String key,
    Map<String, String> value,
  ) async {
    final saved = await preferences.setString(key, jsonEncode(value));
    if (!saved) throw StateError('Unable to persist local lesson data.');
  }

  Future<void> _writeListMap(
    SharedPreferences preferences,
    String key,
    Map<String, List<String>> value,
  ) async {
    final saved = await preferences.setString(key, jsonEncode(value));
    if (!saved) throw StateError('Unable to persist local lesson data.');
  }

  Map<String, String> _readStringMap(String? encoded, String key) {
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw FormatException('Expected "$key" to contain a JSON object.');
    }
    return decoded.map((key, value) {
      if (key is! String || value is! String) {
        throw FormatException('Expected "$key" to contain string values.');
      }
      return MapEntry(key, value);
    });
  }

  Map<String, List<String>> _readListMap(String? encoded, String key) {
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw FormatException('Expected "$key" to contain a JSON object.');
    }
    return decoded.map((key, value) {
      if (key is! String ||
          value is! List ||
          value.any((item) => item is! String)) {
        throw FormatException('Expected "$key" to contain string lists.');
      }
      return MapEntry(key, List<String>.from(value));
    });
  }
}
