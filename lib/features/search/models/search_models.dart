import 'package:flutter/material.dart';

enum SearchResultType {
  course('Cours'),
  lesson('Leçon'),
  book('Livre'),
  document('Document'),
  exercise('Exercice'),
  resource('Ressource'),
  tool('Outil');

  const SearchResultType(this.label);
  final String label;
}

enum SearchLevel { beginner, intermediate, advanced }

enum SearchSort { relevance, recent, popular, shortest, longest, alphabetical }

class SearchHistoryItem {
  const SearchHistoryItem({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  final String id;
  final String query;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'query': query,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      SearchHistoryItem(
        id: json['id'] as String,
        query: json['query'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class SearchFilter {
  const SearchFilter({
    this.types = const {},
    this.levels = const {},
    this.duration,
  });

  final Set<SearchResultType> types;
  final Set<SearchLevel> levels;
  final String? duration;

  SearchFilter copyWith({
    Set<SearchResultType>? types,
    Set<SearchLevel>? levels,
    String? duration,
  }) => SearchFilter(
    types: types ?? this.types,
    levels: levels ?? this.levels,
    duration: duration,
  );

  bool get isEmpty => types.isEmpty && levels.isEmpty && duration == null;
}

class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.route,
    this.keywords = const [],
    this.progress,
    this.accessLabel,
    this.priceLabel,
    this.publishedAt,
    this.popularity = 0,
  });

  final String id;
  final String title;
  final String description;
  final SearchResultType type;
  final String category;
  final SearchLevel level;
  final int durationMinutes;
  final String route;
  final List<String> keywords;
  final double? progress;
  final String? accessLabel;
  final String? priceLabel;
  final DateTime? publishedAt;
  final int popularity;

  IconData get icon => switch (type) {
    SearchResultType.course => Icons.school_outlined,
    SearchResultType.lesson => Icons.menu_book_outlined,
    SearchResultType.book => Icons.auto_stories_outlined,
    SearchResultType.document => Icons.picture_as_pdf_outlined,
    SearchResultType.exercise => Icons.edit_note_rounded,
    SearchResultType.resource => Icons.folder_open_outlined,
    SearchResultType.tool => Icons.auto_awesome_rounded,
  };
}
