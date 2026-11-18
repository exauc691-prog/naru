import '../../subscription/models/subscription_plan.dart';

enum AssistantTaskKind {
  conversation,
  documentAnalysis,
  programming,
  translation,
  generation,
}

enum AIModelCapability { text, documents, code, vision, voice }

enum AIModelCostTier { low, standard, high }

class AIModelDescriptor {
  const AIModelDescriptor({
    required this.id,
    required this.displayName,
    required this.requiredPlan,
    required this.capabilities,
    required this.maximumComplexity,
    required this.costTier,
  });

  final String id;
  final String displayName;
  final SubscriptionPlan requiredPlan;
  final Set<AIModelCapability> capabilities;
  final int maximumComplexity;
  final AIModelCostTier costTier;
}

class AIModelRoutingRequest {
  const AIModelRoutingRequest({
    required this.plan,
    required this.task,
    required this.complexity,
    required this.maximumCostTier,
  });

  final SubscriptionPlan plan;
  final AssistantTaskKind task;
  final int complexity;
  final AIModelCostTier maximumCostTier;
}

class AIModelCatalog {
  const AIModelCatalog(this.models);

  final List<AIModelDescriptor> models;

  AIModelDescriptor? select(AIModelRoutingRequest request) {
    final capability = switch (request.task) {
      AssistantTaskKind.conversation ||
      AssistantTaskKind.generation => AIModelCapability.text,
      AssistantTaskKind.documentAnalysis => AIModelCapability.documents,
      AssistantTaskKind.programming => AIModelCapability.code,
      AssistantTaskKind.translation => AIModelCapability.text,
    };
    final candidates = models.where(
      (model) =>
          request.plan.index >= model.requiredPlan.index &&
          model.capabilities.contains(capability) &&
          request.complexity <= model.maximumComplexity &&
          model.costTier.index <= request.maximumCostTier.index,
    );
    final ordered = candidates.toList()
      ..sort((left, right) {
        final byCost = left.costTier.index.compareTo(right.costTier.index);
        return byCost != 0
            ? byCost
            : right.maximumComplexity.compareTo(left.maximumComplexity);
      });
    return ordered.isEmpty ? null : ordered.first;
  }
}
