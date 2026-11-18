import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/subscription/models/subscription_plan.dart';
import '../data/library_local_store.dart';
import '../data/mock_library_resources.dart';
import '../models/library_resource.dart';

final libraryResourcesProvider = Provider<List<LibraryResource>>(
  (ref) => mockLibraryResources,
);

final libraryResourceByIdProvider = Provider.family<LibraryResource?, String>((
  ref,
  resourceId,
) {
  for (final resource in ref.watch(libraryResourcesProvider)) {
    if (resource.id == resourceId) return resource;
  }
  return null;
});

final libraryLocalStoreProvider = Provider<LibraryLocalStore>(
  (ref) => LibraryLocalStore(),
);

final libraryLocalStateProvider = FutureProvider<LibraryLocalState>(
  (ref) => ref.watch(libraryLocalStoreProvider).load(),
);

SubscriptionFeature? requiredLibraryFeature(
  LibraryResource resource,
) => switch (resource.availability) {
  LibraryAvailability.free => SubscriptionFeature.freeBooks,
  LibraryAvailability.standard => SubscriptionFeature.standardLibraryResources,
  LibraryAvailability.premium => SubscriptionFeature.premiumLibraryResources,
  LibraryAvailability.individualPurchase => null,
};

bool canAccessLibraryResource(SubscriptionPlan plan, LibraryResource resource) {
  final feature = requiredLibraryFeature(resource);
  return feature != null && SubscriptionEntitlements.canAccess(plan, feature);
}

String libraryResourceCategoryName(LibraryResource resource) =>
    libraryCategories[resource.categoryId] ?? resource.categoryId;
