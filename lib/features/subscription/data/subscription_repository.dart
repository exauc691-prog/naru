import '../models/subscription_plan.dart';

abstract interface class SubscriptionRepository {
  Future<SubscriptionPlan> loadPlan();

  Future<void> savePlan(SubscriptionPlan plan);
}
