import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/library/data/library_catalog_filters.dart';
import 'package:naru/features/library/data/mock_library_resources.dart';
import 'package:naru/features/library/models/library_resource.dart';

void main() {
  test('searches and filters by category, type, and access level', () {
    final results = filterLibraryResources(
      resources: mockLibraryResources,
      query: '  algorithmique ',
      categoryId: 'programmation',
      type: LibraryResourceType.book,
      availability: LibraryAvailability.free,
    );

    expect(results.map((resource) => resource.id), ['repere-algorithmique']);
  });

  test('sorts by publication date, popularity, rating, and title', () {
    final recent = filterLibraryResources(
      resources: mockLibraryResources,
      sort: LibraryResourceSort.recent,
    );
    final popular = filterLibraryResources(
      resources: mockLibraryResources,
      sort: LibraryResourceSort.popular,
    );
    final rated = filterLibraryResources(
      resources: mockLibraryResources,
      sort: LibraryResourceSort.rating,
    );
    final alphabetical = filterLibraryResources(
      resources: mockLibraryResources,
      sort: LibraryResourceSort.alphabetical,
    );

    expect(recent.first.id, 'repere-algorithmique');
    expect(popular.first.id, 'repere-algorithmique');
    expect(rated.first.rating, 5);
    expect(alphabetical.first.title, 'Atelier de récits courts');
  });

  test('resource JSON preserves access and distribution rights', () {
    final resource = mockLibraryResources.firstWhere(
      (item) => item.availability == LibraryAvailability.individualPurchase,
    );
    final restored = LibraryResource.fromJson(resource.toJson());

    expect(restored.id, resource.id);
    expect(restored.availability, LibraryAvailability.individualPurchase);
    expect(restored.distributionAuthorized, isTrue);
    expect(restored.rights, LibraryRights.authorOwned);
    expect(restored.individualPriceInCents, 450);
    expect(restored.content, hasLength(3));
  });
}
