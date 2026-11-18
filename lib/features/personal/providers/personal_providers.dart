import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/personal_content_store.dart';
import '../models/personal_content_models.dart';

final personalContentStoreProvider = Provider<PersonalContentStore>(
  (ref) => const PersonalContentStore(),
);

final personalNotesProvider =
    AsyncNotifierProvider<PersonalNotesNotifier, List<PersonalNote>>(
      PersonalNotesNotifier.new,
    );

class PersonalNotesNotifier extends AsyncNotifier<List<PersonalNote>> {
  @override
  Future<List<PersonalNote>> build() =>
      ref.read(personalContentStoreProvider).getNotes();

  Future<void> create({
    required String title,
    required String content,
    required String source,
  }) async {
    await ref.read(personalContentStoreProvider).createNote(
          title: title,
          content: content,
          source: source,
        );
    state = AsyncData(await ref.read(personalContentStoreProvider).getNotes());
  }

  Future<void> editNote(PersonalNote note, {
    required String title,
    required String content,
    required String source,
  }) async {
    await ref.read(personalContentStoreProvider).updateNote(
          id: note.id,
          title: title,
          content: content,
          source: source,
        );
    state = AsyncData(await ref.read(personalContentStoreProvider).getNotes());
  }

  Future<void> delete(String id) async {
    await ref.read(personalContentStoreProvider).deleteNote(id);
    state = AsyncData(await ref.read(personalContentStoreProvider).getNotes());
  }
}
