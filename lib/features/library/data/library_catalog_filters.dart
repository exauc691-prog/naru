import '../models/library_resource.dart';

enum LibraryResourceSort { recent, popular, alphabetical, rating }

List<LibraryResource> filterLibraryResources({
  required Iterable<LibraryResource> resources,
  String query = '',
  String? categoryId,
  LibraryResourceType? type,
  LibraryAvailability? availability,
  LibraryResourceSort sort = LibraryResourceSort.recent,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final result = resources.where((resource) {
    if (categoryId != null && resource.categoryId != categoryId) return false;
    if (type != null && resource.type != type) return false;
    if (availability != null && resource.availability != availability) {
      return false;
    }
    if (normalizedQuery.isEmpty) return true;
    final searchable = [
      resource.title,
      resource.author,
      resource.description,
      resource.categoryId,
      ...resource.topics,
    ].join(' ').toLowerCase();
    return searchable.contains(normalizedQuery);
  }).toList();

  switch (sort) {
    case LibraryResourceSort.recent:
      result.sort(
        (first, second) => second.publishedAt.compareTo(first.publishedAt),
      );
    case LibraryResourceSort.popular:
      result.sort(
        (first, second) => second.popularity.compareTo(first.popularity),
      );
    case LibraryResourceSort.alphabetical:
      result.sort((first, second) => first.title.compareTo(second.title));
    case LibraryResourceSort.rating:
      result.sort((first, second) => second.rating.compareTo(first.rating));
  }
  return List.unmodifiable(result);
}
