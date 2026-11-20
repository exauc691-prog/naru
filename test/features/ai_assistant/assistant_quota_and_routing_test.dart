import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/ai_assistant/data/ai_model_catalog.dart';
import 'package:naru/features/ai_assistant/data/assistant_quota_config.dart';
import 'package:naru/features/ai_assistant/models/assistant_usage.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';

void main() {
  test('quotas are plan-aware and configurable', () {
    const defaults = AssistantQuotaConfig();
    const custom = AssistantQuotaConfig(freeMessages: 2);

    expect(
      defaults.limitFor(SubscriptionPlan.free, AssistantQuotaKind.messages),
      20,
    );
    expect(
      defaults.limitFor(
        SubscriptionPlan.standard,
        AssistantQuotaKind.documentAnalyses,
      ),
      10,
    );
    expect(
      custom.limitFor(SubscriptionPlan.free, AssistantQuotaKind.messages),
      2,
    );
    expect(
      () =>
          const AssistantQuotaConfig(freeMessages: -1)
              .limitFor(SubscriptionPlan.free, AssistantQuotaKind.messages),
      throwsStateError,
    );
  });

  test('model routing respects plan, capability, complexity, and cost', () {
    const catalog = AIModelCatalog([
      AIModelDescriptor(
        id: 'low-cost-text',
        displayName: 'Text demo',
        requiredPlan: SubscriptionPlan.free,
        capabilities: {AIModelCapability.text},
        maximumComplexity: 2,
        costTier: AIModelCostTier.low,
      ),
      AIModelDescriptor(
        id: 'premium-code',
        displayName: 'Code demo',
        requiredPlan: SubscriptionPlan.premium,
        capabilities: {AIModelCapability.code},
        maximumComplexity: 5,
        costTier: AIModelCostTier.high,
      ),
    ]);

    expect(
      catalog
          .select(
            const AIModelRoutingRequest(
              plan: SubscriptionPlan.free,
              task: AssistantTaskKind.conversation,
              complexity: 1,
              maximumCostTier: AIModelCostTier.standard,
            ),
          )
          ?.id,
      'low-cost-text',
    );
    expect(
      catalog.select(
        const AIModelRoutingRequest(
          plan: SubscriptionPlan.free,
          task: AssistantTaskKind.programming,
          complexity: 1,
          maximumCostTier: AIModelCostTier.high,
        ),
      ),
      isNull,
    );
  });

  test('empty model catalog makes no claim of an active provider', () {
    const catalog = AIModelCatalog([]);
    expect(
      catalog.select(
        const AIModelRoutingRequest(
          plan: SubscriptionPlan.premium,
          task: AssistantTaskKind.conversation,
          complexity: 1,
          maximumCostTier: AIModelCostTier.high,
        ),
      ),
      isNull,
    );
  });
}
