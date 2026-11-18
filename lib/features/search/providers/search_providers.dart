import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/repository_providers.dart';
import '../../../shared/models/lesson_model.dart';
import '../../learning/providers/learning_providers.dart';
import '../../library/providers/library_providers.dart';
import '../../practice/providers/practice_providers.dart';
import '../data/search_mock_data.dart';
import '../models/search_models.dart';
import '../services/search_service.dart';

final searchServiceProvider = Provider<SearchService>(
  (ref) => const MockSearchService(),
);

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<SearchHistoryItem>>(
      SearchHistoryNotifier.new,
    );

class SearchHistoryNotifier
    extends AsyncNotifier<List<SearchHistoryItem>> {
  @override
  Future<List<SearchHistoryItem>> build() =>
      ref.read(searchServiceProvider).getHistory();

  Future<void> add(String query) async {
    await ref.read(searchServiceProvider).addHistory(query);
    state = AsyncData(await ref.read(searchServiceProvider).getHistory());
  }

  Future<void> delete(String id) async {
    await ref.read(searchServiceProvider).deleteHistory(id);
    state = AsyncData(await ref.read(searchServiceProvider).getHistory());
  }

  Future<void> clear() async {
    await ref.read(searchServiceProvider).clearHistory();
    state = const AsyncData([]);
  }
}

final searchCatalogProvider = FutureProvider<List<SearchResult>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  final libraryResources = ref.watch(libraryResourcesProvider);
  final exercises = await ref.watch(exercisesProvider.future);
  final repository = ref.watch(learningRepositoryProvider);
  final paths = await ref.watch(learningPathsProvider.future);
  final lessons = <LessonModel>[];
  for (final path in paths) {
    final modules = await repository.getModulesForPath(path.id);
    for (final module in modules) {
      lessons.addAll(await repository.getLessonsForModule(module.id));
    }
  }
  return buildSearchCatalog(
    courses: courses,
    lessons: lessons,
    exercises: exercises,
    resources: libraryResources,
  );
});
