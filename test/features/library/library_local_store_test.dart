import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/library/data/library_local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'persists library actions, reading state, and collection changes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = LibraryLocalStore();

      await store.addToLibrary('resource-1');
      await store.toggleFavorite('resource-1');
      await store.setDownloaded('resource-1', true);
      await store.recordOpened('resource-1', 2);
      await store.toggleBookmark('resource-1', 2);
      await store.saveNote('resource-1', 'À relire demain');
      final collection = await store.createCollection('  Révisions  ');
      await store.addResourceToCollection(collection.id, 'resource-1');
      await store.renameCollection(collection.id, 'Programmation');

      final saved = await LibraryLocalStore().load();
      expect(saved.libraryIds, contains('resource-1'));
      expect(saved.favoriteIds, contains('resource-1'));
      expect(saved.downloadedIds, contains('resource-1'));
      expect(DateTime.tryParse(saved.downloadedAt['resource-1']!), isNotNull);
      expect(saved.readingPages['resource-1'], 2);
      expect(DateTime.tryParse(saved.lastOpenedAt['resource-1']!), isNotNull);
      expect(saved.bookmarks['resource-1'], [2]);
      expect(saved.notes['resource-1'], 'À relire demain');
      expect(saved.collections.single.name, 'Programmation');
      expect(saved.collections.single.resourceIds, ['resource-1']);

      await store.toggleCollectionResource(collection.id, 'resource-1');
      await store.setDownloaded('resource-1', false);
      await store.removeFromLibrary('resource-1');
      final updated = await store.load();
      expect(updated.collections.single.resourceIds, isEmpty);
      expect(updated.downloadedIds, isEmpty);
      expect(updated.libraryIds, isEmpty);
    },
  );

  test('rejects malformed saved data instead of hiding corruption', () async {
    SharedPreferences.setMockInitialValues({'naru.library.local.v1': '[]'});

    expect(LibraryLocalStore().load(), throwsFormatException);
  });
}
