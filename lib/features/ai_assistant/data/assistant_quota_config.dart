import '../../subscription/models/subscription_plan.dart';
import '../models/assistant_usage.dart';

class AssistantQuotaConfig {
  const AssistantQuotaConfig({
    this.freeMessages = 20,
    this.standardMessages = 100,
    this.premiumMessages = 300,
    this.freeDocumentAnalyses = 1,
    this.standardDocumentAnalyses = 10,
    this.premiumDocumentAnalyses = 50,
    this.freeGenerations = 3,
    this.standardGenerations = 25,
    this.premiumGenerations = 100,
    this.freeVoiceMinutes = 0,
    this.standardVoiceMinutes = 0,
    this.premiumVoiceMinutes = 15,
  });

  final int freeMessages;
  final int standardMessages;
  final int premiumMessages;
  final int freeDocumentAnalyses;
  final int standardDocumentAnalyses;
  final int premiumDocumentAnalyses;
  final int freeGenerations;
  final int standardGenerations;
  final int premiumGenerations;
  final int freeVoiceMinutes;
  final int standardVoiceMinutes;
  final int premiumVoiceMinutes;

  int limitFor(SubscriptionPlan plan, AssistantQuotaKind kind) {
    final limit = switch ((plan, kind)) {
      (SubscriptionPlan.free, AssistantQuotaKind.messages) => freeMessages,
      (SubscriptionPlan.standard, AssistantQuotaKind.messages) =>
        standardMessages,
      (SubscriptionPlan.premium, AssistantQuotaKind.messages) =>
        premiumMessages,
      (SubscriptionPlan.free, AssistantQuotaKind.documentAnalyses) =>
        freeDocumentAnalyses,
      (SubscriptionPlan.standard, AssistantQuotaKind.documentAnalyses) =>
        standardDocumentAnalyses,
      (SubscriptionPlan.premium, AssistantQuotaKind.documentAnalyses) =>
        premiumDocumentAnalyses,
      (SubscriptionPlan.free, AssistantQuotaKind.generations) =>
        freeGenerations,
      (SubscriptionPlan.standard, AssistantQuotaKind.generations) =>
        standardGenerations,
      (SubscriptionPlan.premium, AssistantQuotaKind.generations) =>
        premiumGenerations,
      (SubscriptionPlan.free, AssistantQuotaKind.voiceMinutes) =>
        freeVoiceMinutes,
      (SubscriptionPlan.standard, AssistantQuotaKind.voiceMinutes) =>
        standardVoiceMinutes,
      (SubscriptionPlan.premium, AssistantQuotaKind.voiceMinutes) =>
        premiumVoiceMinutes,
    };
    if (limit < 0) {
      throw StateError('Assistant quotas cannot be negative.');
    }
    return limit;
  }

  String get resetDescription =>
      'Les quotas simulés sont réinitialisés chaque jour.';
}

class AssistantQuotaExceeded implements Exception {
  const AssistantQuotaExceeded({
    required this.kind,
    required this.limit,
    required this.plan,
  });

  final AssistantQuotaKind kind;
  final int limit;
  final SubscriptionPlan plan;

  String get message => switch (kind) {
    AssistantQuotaKind.messages =>
      'La limite quotidienne de $limit messages de démonstration est atteinte.',
    AssistantQuotaKind.documentAnalyses =>
      'La limite quotidienne d’analyses de documents est atteinte.',
    AssistantQuotaKind.generations =>
      'La limite quotidienne de générations est atteinte.',
    AssistantQuotaKind.voiceMinutes =>
      'La limite quotidienne des fonctionnalités vocales est atteinte.',
  };

  @override
  String toString() => message;
}
