enum SubscriptionPlan {
  free(
    name: 'Naru Free',
    price: 0,
    description: 'Découvrez Naru, accédez aux ressources gratuites et développez vos connaissances à votre rythme.',
    features: [
      'Cours et livres gratuits',
      'Outils essentiels d’apprentissage',
      'Accès limité à l’assistant IA',
      'Suivi basique de progression',
      'Notes personnelles, exercices et quiz',
    ],
  ),
  standard(
    name: 'Naru Standard',
    price: 2,
    description: 'Passez à une expérience d’apprentissage enrichie avec davantage de ressources, d’outils et de possibilités.',
    features: [
      'Toutes les fonctionnalités Free',
      'Catalogue élargi de formations',
      'Accès étendu aux fonctionnalités IA',
      'Quotas de conversation et de génération supérieurs',
      'Outils de documents et de programmation étendus',
      'Statistiques avancées et personnalisation',
      'Ressources et outils pédagogiques supplémentaires',
    ],
  ),
  premium(
    name: 'Naru Premium',
    price: 10,
    description: 'Profitez de toute la puissance de Naru avec des outils avancés pour apprendre, créer et développer votre potentiel.',
    features: [
      'Toutes les fonctionnalités Standard',
      'Outils IA avancés et analyse de documents',
      'Fonctionnalités vocales avancées',
      'Quotas de démonstration supérieurs',
      'Ressources Premium et outils avancés de révision',
      'Accès prioritaire à certaines nouveautés',
    ],
  );

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.description,
    required this.features,
  });

  final String name;
  final int price;
  final String description;
  final List<String> features;

  String get priceLabel => price == 0 ? '0 \$' : '$price \$';
}

enum SubscriptionFeature {
  freeCourses(
    'Cours gratuits',
    'Accéder aux cours gratuits disponibles dans le catalogue.',
    SubscriptionPlan.free,
  ),
  freeBooks(
    'Livres gratuits',
    'Consulter les livres proposés gratuitement.',
    SubscriptionPlan.free,
  ),
  essentialLearningTools(
    'Outils essentiels',
    'Utiliser les outils de base pour organiser son apprentissage.',
    SubscriptionPlan.free,
  ),
  limitedAssistant(
    'Assistant IA limité',
    'Utiliser l’assistant dans les limites prévues pour Free.',
    SubscriptionPlan.free,
  ),
  basicProgress(
    'Suivi basique',
    'Consulter sa progression d’apprentissage.',
    SubscriptionPlan.free,
  ),
  personalNotes(
    'Notes personnelles',
    'Enregistrer des notes liées aux leçons.',
    SubscriptionPlan.free,
  ),
  quizzes(
    'Exercices et quiz',
    'Répondre aux exercices et quiz gratuits.',
    SubscriptionPlan.free,
  ),
  expandedCatalog(
    'Catalogue élargi',
    'Accéder aux formations réservées à Standard.',
    SubscriptionPlan.standard,
  ),
  extendedAssistant(
    'Fonctionnalités IA étendues',
    'Accéder aux fonctionnalités IA prévues pour Standard.',
    SubscriptionPlan.standard,
  ),
  assistantDocumentTools(
    'Outils de documents',
    'Accéder aux outils de préparation et d’analyse de documents prévus pour Standard.',
    SubscriptionPlan.standard,
  ),
  assistantProgrammingTools(
    'Outils de programmation',
    'Accéder aux modes et outils de programmation étendus.',
    SubscriptionPlan.standard,
  ),
  assistantPremiumDocuments(
    'Analyse avancée de documents',
    'Utiliser les fonctionnalités avancées de documents prévues pour Premium.',
    SubscriptionPlan.premium,
  ),
  assistantVoiceTools(
    'Outils vocaux avancés',
    'Accéder aux fonctionnalités vocales avancées lorsqu’elles seront connectées.',
    SubscriptionPlan.premium,
  ),
  assistantAdvancedGeneration(
    'Génération avancée',
    'Accéder aux outils avancés de génération et d’organisation.',
    SubscriptionPlan.premium,
  ),
  advancedProgress(
    'Statistiques avancées',
    'Consulter des statistiques détaillées de progression.',
    SubscriptionPlan.standard,
  ),
  additionalResources(
    'Ressources supplémentaires',
    'Débloquer des ressources et outils pédagogiques supplémentaires.',
    SubscriptionPlan.standard,
  ),
  standardLibraryResources(
    'Bibliothèque Standard',
    'Accéder aux ressources de la bibliothèque réservées à Standard.',
    SubscriptionPlan.standard,
  ),
  premiumCourses(
    'Cours Premium',
    'Suivre les formations réservées à Naru Premium.',
    SubscriptionPlan.premium,
  ),
  premiumLibraryResources(
    'Bibliothèque Premium',
    'Accéder aux ressources réservées à Naru Premium.',
    SubscriptionPlan.premium,
  ),
  documentAnalysis(
    'Analyse avancée de documents',
    'Accéder aux outils d’analyse de documents prévus pour Premium.',
    SubscriptionPlan.premium,
  ),
  advancedVoiceTools(
    'Fonctionnalités vocales avancées',
    'Accéder aux outils vocaux prévus pour Premium.',
    SubscriptionPlan.premium,
  ),
  advancedRevision(
    'Outils avancés de révision',
    'Accéder aux outils de révision prévus pour Premium.',
    SubscriptionPlan.premium,
  ),
  priorityReleases(
    'Nouveautés en priorité',
    'Accéder en priorité à certaines nouveautés.',
    SubscriptionPlan.premium,
  );

  const SubscriptionFeature(this.title, this.description, this.requiredPlan);

  final String title;
  final String description;
  final SubscriptionPlan requiredPlan;
}

abstract final class SubscriptionEntitlements {
  static bool canAccess(SubscriptionPlan plan, SubscriptionFeature feature) =>
      plan.index >= feature.requiredPlan.index;
}

class SubscriptionPricingConfig {
  const SubscriptionPricingConfig({this.billingPeriodLabel});

  final String? billingPeriodLabel;

  String priceFor(SubscriptionPlan plan) {
    final period = billingPeriodLabel;
    return period == null || plan == SubscriptionPlan.free
        ? plan.priceLabel
        : '${plan.priceLabel} / $period';
  }
}

enum FutureRevenueChannel {
  specializedCourse,
  optionalCertificate,
  courseMarketplace,
  institutionalPartnership,
  liveWorkshop,
  educationalAffiliate,
}

class FutureRevenueOffer {
  const FutureRevenueOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.channel,
    this.priceInCents,
  });

  final String id;
  final String title;
  final String description;
  final FutureRevenueChannel channel;
  final int? priceInCents;
}
