import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_plan.dart';
import 'subscription_repository.dart';

class LocalSubscriptionRepository implements SubscriptionRepository {
  const LocalSubscriptionRepository();

  static const preferenceKey = 'naru.subscription_plan';

  @override
  Future<SubscriptionPlan> loadPlan() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPlan = preferences.getString(preferenceKey);
    if (savedPlan == null) return SubscriptionPlan.free;

    return SubscriptionPlan.values.firstWhere(
      (plan) => plan.name == savedPlan,
      orElse: () => throw FormatException(
        'Unknown saved Naru subscription plan: $savedPlan',
      ),
    );
  }

  @override
  Future<void> savePlan(SubscriptionPlan plan) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(preferenceKey, plan.name);
    if (!saved) {
      throw StateError('Unable to persist the Naru subscription plan.');
    }
  }
}
