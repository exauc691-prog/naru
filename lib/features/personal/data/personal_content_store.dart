import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/personal_content_models.dart';

class PersonalContentStore {
  const PersonalContentStore();

  static const _notesKey = 'naru.personal.notes.v1';
  static const _recentKey = 'naru.personal.recent.v1';

  Future<List<PersonalNote>> getNotes() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_notesKey) ?? const [];
    return [
      for (final value in values)
        PersonalNote.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        ),
    ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  Future<void> createNote({
    required String title,
    required String content,
    required String source,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(content, 'content');
    final now = DateTime.now();
    final note = PersonalNote(
      id: 'note-${now.microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Note personnelle' : title.trim(),
      content: trimmed,
      source: source.trim().isEmpty ? 'Naru' : source.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final notes = await getNotes();
    await _saveNotes([note, ...notes]);
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
    required String source,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(content, 'content');
    final notes = await getNotes();
    await _saveNotes([
      for (final note in notes)
        note.id == id
            ? PersonalNote(
                id: note.id,
                title: title.trim().isEmpty ? 'Note personnelle' : title.trim(),
                content: trimmed,
                source: source.trim(),
                createdAt: note.createdAt,
                updatedAt: DateTime.now(),
              )
            : note,
    ]);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    await _saveNotes(notes.where((note) => note.id != id).toList());
  }

  Future<List<String>> getRecent() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_recentKey) ?? const [];
  }

  Future<void> recordRecent(String route) async {
    final preferences = await SharedPreferences.getInstance();
    final recent = (await getRecent()).where((item) => item != route).toList();
    await preferences.setStringList(_recentKey, [route, ...recent].take(20).toList());
  }

  Future<void> _saveNotes(List<PersonalNote> notes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _notesKey,
      notes.map((note) => jsonEncode(note.toJson())).toList(),
    );
  }
}
