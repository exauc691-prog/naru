import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_subscription_repository.dart';
import '../data/subscription_repository.dart';
import '../models/subscription_plan.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => const LocalSubscriptionRepository(),
);

final subscriptionPricingConfigProvider = Provider<SubscriptionPricingConfig>(
  (ref) => const SubscriptionPricingConfig(),
);

final subscriptionPlanProvider =
    AsyncNotifierProvider<SubscriptionPlanController, SubscriptionPlan>(
      SubscriptionPlanController.new,
    );

class SubscriptionPlanController extends AsyncNotifier<SubscriptionPlan> {
  @override
  Future<SubscriptionPlan> build() =>
      ref.watch(subscriptionRepositoryProvider).loadPlan();

  Future<void> selectPlan(SubscriptionPlan plan) async {
    try {
      await ref.read(subscriptionRepositoryProvider).savePlan(plan);
      state = AsyncData(plan);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
