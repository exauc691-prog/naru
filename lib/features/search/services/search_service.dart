import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_models.dart';

abstract interface class SearchService {
  Future<List<SearchHistoryItem>> getHistory();
  Future<void> addHistory(String query);
  Future<void> deleteHistory(String id);
  Future<void> clearHistory();
  List<String> suggest(String query, List<String> seeds);
  List<SearchResult> search({
    required List<SearchResult> catalog,
    required String query,
    SearchFilter filter = const SearchFilter(),
    SearchSort sort = SearchSort.relevance,
  });
}

class MockSearchService implements SearchService {
  const MockSearchService();

  static const historyKey = 'naru.search.history.v1';

  @override
  Future<List<SearchHistoryItem>> getHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(historyKey) ?? const [];
    return [
      for (final value in stored)
        SearchHistoryItem.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        ),
    ];
  }

  @override
  Future<void> addHistory(String query) async {
    final preferences = await SharedPreferences.getInstance();
    final history = await getHistory();
    final item = SearchHistoryItem(
      id: 'search-${DateTime.now().microsecondsSinceEpoch}',
      query: query.trim(),
      createdAt: DateTime.now(),
    );
    final next = [
      item,
      ...history.where((entry) =>
          entry.query.toLowerCase() != query.trim().toLowerCase()),
    ].take(10);
    await preferences.setStringList(
      historyKey,
      next.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteHistory(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final history = await getHistory();
    await preferences.setStringList(
      historyKey,
      history
          .where((entry) => entry.id != id)
          .map((entry) => jsonEncode(entry.toJson()))
          .toList(),
    );
  }

  @override
  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(historyKey);
  }

  @override
  List<String> suggest(String query, List<String> seeds) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final suggestions = {
      for (final seed in seeds)
        if (seed.toLowerCase().contains(normalized) ||
            normalized.contains(seed.toLowerCase()))
          seed,
    }.toList();
    return suggestions.take(6).toList();
  }

  @override
  List<SearchResult> search({
    required List<SearchResult> catalog,
    required String query,
    SearchFilter filter = const SearchFilter(),
    SearchSort sort = SearchSort.relevance,
  }) {
    final terms = query.toLowerCase().trim().split(RegExp(r'\s+'))
      ..removeWhere((term) => term.isEmpty);
    final results = catalog.where((result) {
      if (filter.types.isNotEmpty && !filter.types.contains(result.type)) {
        return false;
      }
      if (filter.levels.isNotEmpty &&
          !filter.levels.contains(result.level)) {
        return false;
      }
      if (filter.duration != null) {
        final duration = result.durationMinutes;
        final matches = switch (filter.duration) {
          'short' => duration < 30,
          'medium' => duration >= 30 && duration <= 120,
          'long' => duration > 120 && duration <= 300,
          'veryLong' => duration > 300,
          _ => true,
        };
        if (!matches) return false;
      }
      if (terms.isEmpty) return true;
      final haystack = [
        result.title,
        result.description,
        result.category,
        ...result.keywords,
      ].join(' ').toLowerCase();
      return terms.every(haystack.contains);
    }).toList();

    switch (sort) {
      case SearchSort.relevance:
        results.sort((left, right) {
          final leftScore = _relevance(left, terms);
          final rightScore = _relevance(right, terms);
          return rightScore.compareTo(leftScore);
        });
      case SearchSort.recent:
        results.sort((left, right) =>
            (right.publishedAt ?? DateTime(1970))
                .compareTo(left.publishedAt ?? DateTime(1970)));
      case SearchSort.popular:
        results.sort((left, right) =>
            right.popularity.compareTo(left.popularity));
      case SearchSort.shortest:
        results.sort((left, right) =>
            left.durationMinutes.compareTo(right.durationMinutes));
      case SearchSort.longest:
        results.sort((left, right) =>
            right.durationMinutes.compareTo(left.durationMinutes));
      case SearchSort.alphabetical:
        results.sort((left, right) =>
            left.title.toLowerCase().compareTo(right.title.toLowerCase()));
    }
    return results;
  }

  int _relevance(SearchResult result, List<String> terms) {
    final title = result.title.toLowerCase();
    final category = result.category.toLowerCase();
    final description = result.description.toLowerCase();
    final keywords = result.keywords.join(' ').toLowerCase();
    var score = 0;
    for (final term in terms) {
      if (title.contains(term)) score += 8;
      if (category.contains(term)) score += 5;
      if (keywords.contains(term)) score += 4;
      if (description.contains(term)) score += 2;
    }
    return score;
  }
}
