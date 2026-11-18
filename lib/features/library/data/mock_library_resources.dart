import '../models/library_resource.dart';

final mockLibraryResources = List<LibraryResource>.unmodifiable([
  _resource(
    id: 'repere-algorithmique',
    title: 'Premiers repères en algorithmique',
    author: 'Équipe pédagogique Naru',
    categoryId: 'programmation',
    description:
        'Un guide fictif pour découvrir les instructions, les variables et '
        'les étapes qui composent un petit programme.',
    type: LibraryResourceType.book,
    availability: LibraryAvailability.free,
    format: LibraryFormat.epub,
    publishedAt: DateTime.utc(2026, 11, 12),
    topics: ['algorithmes', 'programmation', 'débutant'],
    popularity: 96,
    rating: 5,
    firstPage:
        'Un algorithme décrit une suite d’étapes ordonnées pour résoudre un '
        'problème. Il peut être expliqué avec des mots, un schéma ou du code.',
    secondPage:
        'Pour préparer une recette, on rassemble les ingrédients, on suit les '
        'étapes puis on vérifie le résultat. Un programme suit la même idée.',
    thirdPage:
        'Avant de coder, formule le résultat attendu, découpe le travail en '
        'petites étapes et vérifie chaque étape avec un exemple.',
    isNew: true,
  ),
  _resource(
    id: 'donnees-quotidien',
    title: 'Comprendre les données au quotidien',
    author: 'Lina Moreau (auteure fictive)',
    categoryId: 'informatique',
    description:
        'Des exemples originaux pour apprendre à observer, organiser et '
        'interpréter des données simples sans présumer de leur qualité.',
    type: LibraryResourceType.guide,
    availability: LibraryAvailability.free,
    format: LibraryFormat.guide,
    publishedAt: DateTime.utc(2026, 10, 28),
    topics: ['données', 'tableaux', 'lecture critique'],
    popularity: 88,
    rating: 5,
    firstPage:
        'Une donnée prend son sens dans un contexte. Avant de comparer des '
        'valeurs, identifie ce qui a été mesuré, par qui et à quel moment.',
    secondPage:
        'Un tableau clair nomme ses colonnes et précise ses unités. Une valeur '
        'isolée ne suffit pas toujours à décrire une tendance.',
    thirdPage:
        'Note la source et les limites de chaque mesure. Une conclusion '
        'prudente distingue ce que les données montrent de ce qu’elles ne disent pas.',
  ),
  _resource(
    id: 'ia-responsable',
    title: 'Introduction à l’intelligence artificielle responsable',
    author: 'Atelier Naru (contenu fictif)',
    categoryId: 'intelligence-artificielle',
    description:
        'Une introduction originale aux usages, aux limites et aux questions '
        'de responsabilité liées aux systèmes automatisés.',
    type: LibraryResourceType.courseMaterial,
    availability: LibraryAvailability.premium,
    format: LibraryFormat.pdf,
    publishedAt: DateTime.utc(2026, 11, 5),
    topics: ['intelligence artificielle', 'données', 'responsabilité'],
    popularity: 91,
    rating: 5,
    firstPage:
        'Un système d’intelligence artificielle traite des entrées pour '
        'produire des résultats. Son comportement dépend de sa conception, '
        'de ses données et de son contexte d’utilisation.',
    secondPage:
        'Évaluer un outil implique de vérifier ses erreurs possibles, ses '
        'limites et les personnes qui peuvent être affectées par ses décisions.',
    thirdPage:
        'Un usage responsable prévoit une supervision adaptée, explique les '
        'limites et permet de corriger les résultats inappropriés.',
  ),
  _resource(
    id: 'observer-sciences',
    title: 'Observer et raisonner en sciences',
    author: 'Noé Diallo (auteur fictif)',
    categoryId: 'sciences',
    description:
        'Une fiche de méthode fictive pour transformer une observation en '
        'question puis en démarche vérifiable.',
    type: LibraryResourceType.revisionSheet,
    availability: LibraryAvailability.free,
    format: LibraryFormat.pdf,
    publishedAt: DateTime.utc(2026, 9, 18),
    topics: ['observation', 'hypothèse', 'méthode'],
    popularity: 72,
    rating: 4,
    firstPage:
        'Une observation décrit un phénomène sans expliquer immédiatement '
        'sa cause. Une question précise aide à orienter l’exploration.',
    secondPage:
        'Une hypothèse propose une explication que l’on peut confronter à des '
        'observations ou à une expérience réalisable.',
    thirdPage:
        'Garde une trace des étapes, des conditions et des résultats afin '
        'qu’une autre personne puisse comprendre la démarche.',
  ),
  _resource(
    id: 'proportions-graphiques',
    title: 'Proportions et graphiques : les bases',
    author: 'Équipe pédagogique Naru',
    categoryId: 'mathematiques',
    description:
        'Un support de cours fictif pour lire une proportion, choisir une '
        'représentation et expliquer un résultat.',
    type: LibraryResourceType.courseMaterial,
    availability: LibraryAvailability.free,
    format: LibraryFormat.text,
    publishedAt: DateTime.utc(2026, 8, 24),
    topics: ['proportions', 'graphiques', 'calcul'],
    popularity: 85,
    rating: 4,
    firstPage:
        'Une proportion compare une partie à un ensemble. Vérifie toujours '
        'la quantité de référence avant de calculer ou de comparer.',
    secondPage:
        'Un graphique doit rendre visibles les unités, les catégories et '
        'l’échelle. Une échelle tronquée peut modifier la perception.',
    thirdPage:
        'Lis le titre, les axes et la légende avant de décrire une tendance. '
        'Appuie chaque conclusion sur une valeur observable.',
  ),
  _resource(
    id: 'atelier-recits',
    title: 'Atelier de récits courts',
    author: 'Mila Renard (auteure fictive)',
    categoryId: 'litterature',
    description:
        'Des exercices de lecture et d’écriture originaux autour du point de '
        'vue, du rythme et de la construction d’un récit.',
    type: LibraryResourceType.book,
    availability: LibraryAvailability.standard,
    format: LibraryFormat.epub,
    publishedAt: DateTime.utc(2026, 10, 2),
    topics: ['lecture', 'écriture', 'récit'],
    popularity: 78,
    rating: 5,
    firstPage:
        'Un récit court choisit peu d’éléments et les organise avec intention. '
        'Un détail précis peut installer un lieu ou une émotion.',
    secondPage:
        'Le point de vue détermine ce que le lecteur sait. En le faisant '
        'évoluer, on modifie la tension et la proximité avec les personnages.',
    thirdPage:
        'Relis chaque phrase en demandant si elle fait avancer l’action, '
        'précise le point de vue ou renforce l’atmosphère.',
  ),
  _resource(
    id: 'chronologie-civile',
    title: 'Construire une chronologie historique',
    author: 'Équipe pédagogique Naru',
    categoryId: 'histoire',
    description:
        'Une fiche fictive pour situer des événements, comparer des sources '
        'et expliquer les liens entre différentes périodes.',
    type: LibraryResourceType.revisionSheet,
    availability: LibraryAvailability.free,
    format: LibraryFormat.pdf,
    publishedAt: DateTime.utc(2026, 7, 16),
    topics: ['chronologie', 'sources', 'repères'],
    popularity: 64,
    rating: 4,
    firstPage:
        'Une chronologie aide à situer des événements, mais ne remplace pas '
        'leur explication. Sépare les dates des interprétations.',
    secondPage:
        'Compare le contexte, l’auteur et le but de chaque source. Des '
        'documents différents peuvent éclairer des aspects complémentaires.',
    thirdPage:
        'Présente les repères choisis et justifie les liens de cause, de '
        'conséquence ou de simultanéité que tu proposes.',
  ),
  _resource(
    id: 'budget-projet',
    title: 'Lire le budget d’un projet',
    author: 'Amine Costa (auteur fictif)',
    categoryId: 'economie',
    description:
        'Un guide de démonstration pour distinguer coûts, recettes et '
        'hypothèses dans un budget pédagogique.',
    type: LibraryResourceType.guide,
    availability: LibraryAvailability.standard,
    format: LibraryFormat.guide,
    publishedAt: DateTime.utc(2026, 6, 30),
    topics: ['budget', 'coûts', 'prévisions'],
    popularity: 69,
    rating: 4,
    firstPage:
        'Un budget rassemble des estimations pour une période définie. '
        'Précise les unités et distingue les montants observés des prévisions.',
    secondPage:
        'Classe les dépenses par catégorie et indique les hypothèses derrière '
        'chaque estimation. Un changement d’hypothèse peut modifier le résultat.',
    thirdPage:
        'Compare les prévisions aux valeurs réalisées et documente les écarts '
        'pour mieux préparer la période suivante.',
  ),
  _resource(
    id: 'langues-conversation',
    title: 'Pratiquer une conversation en langue',
    author: 'Sara El Mansour (auteure fictive)',
    categoryId: 'langues',
    description:
        'Un support pédagogique fictif pour préparer une conversation, '
        'reformuler une idée et enrichir son vocabulaire.',
    type: LibraryResourceType.courseMaterial,
    availability: LibraryAvailability.free,
    format: LibraryFormat.text,
    publishedAt: DateTime.utc(2026, 5, 21),
    topics: ['langues', 'expression orale', 'vocabulaire'],
    popularity: 74,
    rating: 4,
    firstPage:
        'Une conversation progresse quand les interlocuteurs écoutent, '
        'posent des questions et reformulent les idées importantes.',
    secondPage:
        'Prépare quelques expressions utiles par thème, puis adapte-les au '
        'contexte plutôt que de réciter une réponse apprise.',
    thirdPage:
        'Après l’échange, note les mots nouveaux et les formulations à '
        'réutiliser lors d’une prochaine conversation.',
  ),
  _resource(
    id: 'idee-projet',
    title: 'De l’idée au projet : carnet de lancement',
    author: 'Atelier Naru (contenu fictif)',
    categoryId: 'entrepreneuriat',
    description:
        'Un carnet fictif pour clarifier un besoin, identifier les personnes '
        'concernées et tester une première proposition.',
    type: LibraryResourceType.guide,
    availability: LibraryAvailability.individualPurchase,
    format: LibraryFormat.guide,
    publishedAt: DateTime.utc(2026, 11, 1),
    topics: ['projet', 'besoin', 'prototypage'],
    popularity: 82,
    rating: 5,
    individualPriceInCents: 450,
    revenueChannel: LibraryRevenueChannel.educationalDocumentSale,
    firstPage:
        'Commence par décrire une difficulté concrète et les personnes qui '
        'la rencontrent. Une idée gagne en clarté quand son contexte est précis.',
    secondPage:
        'Échange avec les personnes concernées avant de construire une '
        'solution. Note les besoins qui se répètent et ceux qui divergent.',
    thirdPage:
        'Formule une hypothèse simple, teste-la à petite échelle et conserve '
        'les retours pour décider de la suite.',
  ),
  _resource(
    id: 'habitudes-apprentissage',
    title: 'Installer des habitudes d’apprentissage',
    author: 'Jade Morel (auteure fictive)',
    categoryId: 'developpement-personnel',
    description:
        'Des repères fictifs pour organiser de petites séances de travail et '
        'observer ce qui aide à maintenir une routine.',
    type: LibraryResourceType.book,
    availability: LibraryAvailability.premium,
    format: LibraryFormat.epub,
    publishedAt: DateTime.utc(2026, 10, 15),
    topics: ['habitudes', 'organisation', 'révision'],
    popularity: 89,
    rating: 5,
    firstPage:
        'Une routine durable commence par une action assez simple pour être '
        'répétée. Choisis un moment et un objectif réalistes.',
    secondPage:
        'Des séances courtes et régulières peuvent faciliter le rappel. '
        'Prévois une pause et varie les exercices pour maintenir l’attention.',
    thirdPage:
        'Observe ce qui fonctionne sans chercher une méthode universelle. '
        'Ajuste la durée, le lieu ou le rythme selon tes contraintes.',
  ),
  _resource(
    id: 'concevoir-une-lecon',
    title: 'Concevoir une leçon claire',
    author: 'Équipe pédagogique Naru',
    categoryId: 'education',
    description:
        'Un support fictif pour relier un objectif pédagogique, une activité '
        'et une vérification des apprentissages.',
    type: LibraryResourceType.courseMaterial,
    availability: LibraryAvailability.standard,
    format: LibraryFormat.pdf,
    publishedAt: DateTime.utc(2026, 9, 30),
    topics: ['pédagogie', 'objectifs', 'évaluation'],
    popularity: 67,
    rating: 4,
    firstPage:
        'Un objectif décrit ce que l’apprenant pourra faire. Il aide à choisir '
        'les exemples, les activités et la manière de vérifier la compréhension.',
    secondPage:
        'Une progression présente une idée à la fois, puis propose une '
        'occasion de l’utiliser dans une situation proche.',
    thirdPage:
        'Une vérification courte révèle les notions à reprendre et donne à '
        'l’apprenant une indication utile sur la suite.',
  ),
]);

LibraryResource _resource({
  required String id,
  required String title,
  required String author,
  required String categoryId,
  required String description,
  required LibraryResourceType type,
  required LibraryAvailability availability,
  required LibraryFormat format,
  required DateTime publishedAt,
  required List<String> topics,
  required int popularity,
  required int rating,
  required String firstPage,
  required String secondPage,
  required String thirdPage,
  int? individualPriceInCents,
  LibraryRevenueChannel? revenueChannel,
  bool isNew = false,
}) => LibraryResource(
  id: id,
  title: title,
  author: author,
  categoryId: categoryId,
  description: description,
  type: type,
  availability: availability,
  format: format,
  language: 'Français',
  rights: LibraryRights.authorOwned,
  rightsHolder: author,
  distributionAuthorized: true,
  pages: 3,
  publisher: 'Éditions Naru (éditeur fictif)',
  licenseDetails: 'Contenu pédagogique fictif créé pour la démonstration.',
  difficulty: 'Tous niveaux',
  rating: rating,
  popularity: popularity,
  publishedAt: publishedAt,
  topics: topics,
  content: [
    LibraryTextPage(heading: 'Découvrir le sujet', paragraphs: [firstPage]),
    LibraryTextPage(heading: 'Mettre en pratique', paragraphs: [secondPage]),
    LibraryTextPage(heading: 'À retenir', paragraphs: [thirdPage]),
  ],
  individualPriceInCents: individualPriceInCents,
  revenueChannel: revenueChannel,
  fileSizeLabel: format == LibraryFormat.pdf
      ? '420 Ko (simulé)'
      : '280 Ko (simulé)',
  isNew: isNew,
);
