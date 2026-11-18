import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/model_json.dart';
import '../models/library_collection.dart';

class LibraryLocalState {
  LibraryLocalState({
    Set<String> libraryIds = const {},
    Set<String> favoriteIds = const {},
    Set<String> downloadedIds = const {},
    Map<String, int> readingPages = const {},
    Map<String, String> lastOpenedAt = const {},
    Map<String, String> downloadedAt = const {},
    Map<String, List<int>> bookmarks = const {},
    Map<String, String> notes = const {},
    List<LibraryCollection> collections = const [],
  }) : libraryIds = Set.unmodifiable(libraryIds),
       favoriteIds = Set.unmodifiable(favoriteIds),
       downloadedIds = Set.unmodifiable(downloadedIds),
       readingPages = Map.unmodifiable(readingPages),
       lastOpenedAt = Map.unmodifiable(lastOpenedAt),
       downloadedAt = Map.unmodifiable(downloadedAt),
       bookmarks = Map.unmodifiable({
         for (final entry in bookmarks.entries)
           entry.key: List<int>.unmodifiable(entry.value),
       }),
       notes = Map.unmodifiable(notes),
       collections = List.unmodifiable(collections);

  final Set<String> libraryIds;
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final Map<String, int> readingPages;
  final Map<String, String> lastOpenedAt;
  final Map<String, String> downloadedAt;
  final Map<String, List<int>> bookmarks;
  final Map<String, String> notes;
  final List<LibraryCollection> collections;

  LibraryLocalState copyWith({
    Set<String>? libraryIds,
    Set<String>? favoriteIds,
    Set<String>? downloadedIds,
    Map<String, int>? readingPages,
    Map<String, String>? lastOpenedAt,
    Map<String, String>? downloadedAt,
    Map<String, List<int>>? bookmarks,
    Map<String, String>? notes,
    List<LibraryCollection>? collections,
  }) => LibraryLocalState(
    libraryIds: libraryIds ?? this.libraryIds,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    downloadedIds: downloadedIds ?? this.downloadedIds,
    readingPages: readingPages ?? this.readingPages,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    bookmarks: bookmarks ?? this.bookmarks,
    notes: notes ?? this.notes,
    collections: collections ?? this.collections,
  );

  factory LibraryLocalState.fromJson(ModelJsonMap json) => LibraryLocalState(
    libraryIds: _stringSet(json, 'libraryIds'),
    favoriteIds: _stringSet(json, 'favoriteIds'),
    downloadedIds: _stringSet(json, 'downloadedIds'),
    readingPages: _intMap(json, 'readingPages'),
    lastOpenedAt: _stringMap(json, 'lastOpenedAt'),
    downloadedAt: _stringMap(json, 'downloadedAt'),
    bookmarks: _intListMap(json, 'bookmarks'),
    notes: _stringMap(json, 'notes'),
    collections: json['collections'] == null
        ? const []
        : ModelJson.objectList(json, 'collections', LibraryCollection.fromJson),
  );

  ModelJsonMap toJson() => {
    'libraryIds': libraryIds.toList()..sort(),
    'favoriteIds': favoriteIds.toList()..sort(),
    'downloadedIds': downloadedIds.toList()..sort(),
    'readingPages': readingPages,
    'lastOpenedAt': lastOpenedAt,
    'downloadedAt': downloadedAt,
    'bookmarks': bookmarks,
    'notes': notes,
    'collections': collections
        .map((collection) => collection.toJson())
        .toList(),
  };
}

class LibraryLocalStore {
  static const _storageKey = 'naru.library.local.v1';

  Future<LibraryLocalState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null) return LibraryLocalState();
    final decoded = jsonDecode(encoded);
    return LibraryLocalState.fromJson(ModelJson.object(decoded, _storageKey));
  }

  Future<void> addToLibrary(String resourceId) => _update((state) {
    final ids = {...state.libraryIds, resourceId};
    return state.copyWith(libraryIds: ids);
  });

  Future<void> removeFromLibrary(String resourceId) => _update((state) {
    final ids = {...state.libraryIds}..remove(resourceId);
    return state.copyWith(libraryIds: ids);
  });

  Future<void> toggleFavorite(String resourceId) => _update((state) {
    final ids = {...state.favoriteIds};
    if (!ids.add(resourceId)) ids.remove(resourceId);
    return state.copyWith(favoriteIds: ids);
  });

  Future<void> setDownloaded(String resourceId, bool downloaded) =>
      _update((state) {
        final ids = {...state.downloadedIds};
        final downloadedAt = {...state.downloadedAt};
        if (downloaded) {
          ids.add(resourceId);
          downloadedAt[resourceId] = DateTime.now().toIso8601String();
        } else {
          ids.remove(resourceId);
          downloadedAt.remove(resourceId);
        }
        return state.copyWith(downloadedIds: ids, downloadedAt: downloadedAt);
      });

  Future<void> recordOpened(String resourceId, int page) => _update((state) {
    final pages = {...state.readingPages, resourceId: page};
    final openedAt = {
      ...state.lastOpenedAt,
      resourceId: DateTime.now().toIso8601String(),
    };
    return state.copyWith(readingPages: pages, lastOpenedAt: openedAt);
  });

  Future<void> toggleBookmark(String resourceId, int page) => _update((state) {
    final bookmarks = {
      for (final entry in state.bookmarks.entries) entry.key: [...entry.value],
    };
    final pages = bookmarks[resourceId] ?? <int>[];
    if (!pages.remove(page)) pages.add(page);
    pages.sort();
    if (pages.isEmpty) {
      bookmarks.remove(resourceId);
    } else {
      bookmarks[resourceId] = pages;
    }
    return state.copyWith(bookmarks: bookmarks);
  });

  Future<void> saveNote(String resourceId, String note) => _update((state) {
    final notes = {...state.notes};
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      notes.remove(resourceId);
    } else {
      notes[resourceId] = trimmed;
    }
    return state.copyWith(notes: notes);
  });

  Future<LibraryCollection> createCollection(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Collection name cannot be empty.',
      );
    }
    final now = DateTime.now();
    final collection = LibraryCollection(
      id: 'collection-${now.microsecondsSinceEpoch}',
      name: trimmed,
      createdAt: now,
      updatedAt: now,
      resourceIds: const [],
    );
    await _update(
      (state) =>
          state.copyWith(collections: [...state.collections, collection]),
    );
    return collection;
  }

  Future<void> renameCollection(String collectionId, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Collection name cannot be empty.',
      );
    }
    return _update((state) {
      var found = false;
      final collections = state.collections.map((collection) {
        if (collection.id != collectionId) return collection;
        found = true;
        return LibraryCollection(
          id: collection.id,
          name: trimmed,
          createdAt: collection.createdAt,
          updatedAt: DateTime.now(),
          resourceIds: collection.resourceIds,
        );
      }).toList();
      if (!found) throw StateError('Library collection not found.');
      return state.copyWith(collections: collections);
    });
  }

  Future<void> deleteCollection(String collectionId) => _update((state) {
    final collections = state.collections
        .where((collection) => collection.id != collectionId)
        .toList();
    if (collections.length == state.collections.length) {
      throw StateError('Library collection not found.');
    }
    return state.copyWith(collections: collections);
  });

  Future<void> toggleCollectionResource(
    String collectionId,
    String resourceId,
  ) => _setCollectionResource(collectionId, resourceId, present: null);

  Future<void> addResourceToCollection(
    String collectionId,
    String resourceId,
  ) => _setCollectionResource(collectionId, resourceId, present: true);

  Future<void> _setCollectionResource(
    String collectionId,
    String resourceId, {
    required bool? present,
  }) => _update((state) {
    var found = false;
    final collections = state.collections.map((collection) {
      if (collection.id != collectionId) return collection;
      found = true;
      final ids = [...collection.resourceIds];
      if (present == true) {
        if (!ids.contains(resourceId)) ids.add(resourceId);
      } else if (present == false) {
        ids.remove(resourceId);
      } else if (!ids.remove(resourceId)) {
        ids.add(resourceId);
      }
      return LibraryCollection(
        id: collection.id,
        name: collection.name,
        createdAt: collection.createdAt,
        updatedAt: DateTime.now(),
        resourceIds: ids,
      );
    }).toList();
    if (!found) throw StateError('Library collection not found.');
    return state.copyWith(collections: collections);
  });

  Future<void> _update(
    LibraryLocalState Function(LibraryLocalState) update,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    final state = encoded == null
        ? LibraryLocalState()
        : LibraryLocalState.fromJson(
            ModelJson.object(jsonDecode(encoded), _storageKey),
          );
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(update(state).toJson()),
    );
    if (!saved) throw StateError('Unable to persist the local library.');
  }
}

Set<String> _stringSet(ModelJsonMap json, String key) {
  final value = json[key];
  if (value == null) return {};
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('Expected "$key" to be a list of strings.');
  }
  return value.cast<String>().toSet();
}

Map<String, String> _stringMap(ModelJsonMap json, String key) {
  final value = json[key];
  if (value == null) return {};
  if (value is! Map ||
      value.entries.any(
        (entry) => entry.key is! String || entry.value is! String,
      )) {
    throw FormatException('Expected "$key" to contain string values.');
  }
  return value.cast<String, String>();
}

Map<String, int> _intMap(ModelJsonMap json, String key) {
  final value = json[key];
  if (value == null) return {};
  if (value is! Map ||
      value.entries.any(
        (entry) => entry.key is! String || entry.value is! int,
      )) {
    throw FormatException('Expected "$key" to contain integer values.');
  }
  return value.cast<String, int>();
}

Map<String, List<int>> _intListMap(ModelJsonMap json, String key) {
  final value = json[key];
  if (value == null) return {};
  if (value is! Map ||
      value.entries.any(
        (entry) =>
            entry.key is! String ||
            entry.value is! List ||
            (entry.value as List).any((item) => item is! int),
      )) {
    throw FormatException('Expected "$key" to contain integer lists.');
  }
  return {
    for (final entry in value.entries)
      entry.key as String: (entry.value as List).cast<int>(),
  };
}
