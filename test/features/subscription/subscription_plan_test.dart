import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/subscription/data/local_subscription_repository.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads Free by default and persists a selected plan locally', () async {
    SharedPreferences.setMockInitialValues({});
    const repository = LocalSubscriptionRepository();

    expect(await repository.loadPlan(), SubscriptionPlan.free);
    await repository.savePlan(SubscriptionPlan.standard);
    expect(await repository.loadPlan(), SubscriptionPlan.standard);
  });

  test('feature access follows the plan hierarchy', () {
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.free,
        SubscriptionFeature.quizzes,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.free,
        SubscriptionFeature.advancedProgress,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.advancedProgress,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.free,
        SubscriptionFeature.standardLibraryResources,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.standardLibraryResources,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.free,
        SubscriptionFeature.assistantDocumentTools,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.assistantDocumentTools,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.free,
        SubscriptionFeature.assistantProgrammingTools,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.premiumCourses,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.premium,
        SubscriptionFeature.premiumCourses,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.premiumLibraryResources,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.premium,
        SubscriptionFeature.premiumLibraryResources,
      ),
      isTrue,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.standard,
        SubscriptionFeature.assistantAdvancedGeneration,
      ),
      isFalse,
    );
    expect(
      SubscriptionEntitlements.canAccess(
        SubscriptionPlan.premium,
        SubscriptionFeature.assistantAdvancedGeneration,
      ),
      isTrue,
    );
  });

  test('billing period is omitted unless configured', () {
    expect(
      const SubscriptionPricingConfig().priceFor(SubscriptionPlan.standard),
      '2 \$',
    );
    expect(
      const SubscriptionPricingConfig(
        billingPeriodLabel: 'période configurable',
      ).priceFor(SubscriptionPlan.standard),
      '2 \$ / période configurable',
    );
  });
}
