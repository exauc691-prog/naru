import '../../../shared/models/model_json.dart';

enum LibraryResourceType {
  book('Livre'),
  pdf('Document PDF'),
  guide('Guide'),
  revisionSheet('Fiche de révision'),
  courseMaterial('Support de cours');

  const LibraryResourceType(this.label);

  final String label;
}

enum LibraryAvailability {
  free('Gratuit'),
  standard('Standard'),
  premium('Premium'),
  individualPurchase('Achat individuel');

  const LibraryAvailability(this.label);

  final String label;
}

enum LibraryFormat {
  text('Texte'),
  epub('EPUB de démonstration'),
  pdf('PDF de démonstration'),
  guide('Guide de démonstration');

  const LibraryFormat(this.label);

  final String label;
}

enum LibraryRights {
  publicDomain('Domaine public'),
  licensed('Sous licence'),
  authorOwned('Appartient à son auteur'),
  authorizedDistribution('Distribution autorisée'),
  individualSale('Vente individuelle');

  const LibraryRights(this.label);

  final String label;
}

enum LibraryRevenueChannel {
  digitalBookSale,
  educationalDocumentSale,
  publisherPartnership,
  authorizedMarketplace,
  institutionalOffer,
}

class LibraryTextPage {
  LibraryTextPage({required this.heading, required List<String> paragraphs})
    : paragraphs = List.unmodifiable(paragraphs);

  final String heading;
  final List<String> paragraphs;

  factory LibraryTextPage.fromJson(ModelJsonMap json) => LibraryTextPage(
    heading: ModelJson.requiredString(json, 'heading'),
    paragraphs: ModelJson.stringList(json, 'paragraphs'),
  );

  ModelJsonMap toJson() => {'heading': heading, 'paragraphs': paragraphs};
}

class LibraryResource {
  LibraryResource({
    required this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.description,
    required this.type,
    required this.availability,
    required this.format,
    required this.language,
    required this.rights,
    required this.rightsHolder,
    required this.distributionAuthorized,
    required this.pages,
    required this.rating,
    required this.popularity,
    required this.publishedAt,
    required List<String> topics,
    required List<LibraryTextPage> content,
    this.publisher,
    this.licenseDetails,
    this.difficulty,
    this.individualPriceInCents,
    this.revenueChannel,
    this.fileSizeLabel,
    this.isNew = false,
    this.isDownloadable = true,
  }) : topics = List.unmodifiable(topics),
       content = List.unmodifiable(content);

  final String id;
  final String title;
  final String author;
  final String categoryId;
  final String description;
  final LibraryResourceType type;
  final LibraryAvailability availability;
  final LibraryFormat format;
  final String language;
  final String rightsHolder;
  final LibraryRights rights;
  final bool distributionAuthorized;
  final int? pages;
  final String? publisher;
  final String? licenseDetails;
  final String? difficulty;
  final int rating;
  final int popularity;
  final DateTime publishedAt;
  final List<String> topics;
  final List<LibraryTextPage> content;
  final int? individualPriceInCents;
  final LibraryRevenueChannel? revenueChannel;
  final String? fileSizeLabel;
  final bool isNew;
  final bool isDownloadable;

  String get coverGlyph => switch (type) {
    LibraryResourceType.book => 'Aa',
    LibraryResourceType.pdf => 'PDF',
    LibraryResourceType.guide => 'GUIDE',
    LibraryResourceType.revisionSheet => 'FICHE',
    LibraryResourceType.courseMaterial => 'COURS',
  };

  factory LibraryResource.fromJson(ModelJsonMap json) => LibraryResource(
    id: ModelJson.requiredString(json, 'id'),
    title: ModelJson.requiredString(json, 'title'),
    author: ModelJson.requiredString(json, 'author'),
    categoryId: ModelJson.requiredString(json, 'categoryId'),
    description: ModelJson.requiredString(json, 'description'),
    type: ModelJson.enumValue(LibraryResourceType.values, json['type'], 'type'),
    availability: ModelJson.enumValue(
      LibraryAvailability.values,
      json['availability'],
      'availability',
    ),
    format: ModelJson.enumValue(LibraryFormat.values, json['format'], 'format'),
    language: ModelJson.requiredString(json, 'language'),
    rights: ModelJson.enumValue(LibraryRights.values, json['rights'], 'rights'),
    rightsHolder: ModelJson.requiredString(json, 'rightsHolder'),
    distributionAuthorized: ModelJson.requiredBool(
      json,
      'distributionAuthorized',
    ),
    pages: ModelJson.optionalInt(json, 'pages'),
    publisher: ModelJson.optionalString(json, 'publisher'),
    licenseDetails: ModelJson.optionalString(json, 'licenseDetails'),
    difficulty: ModelJson.optionalString(json, 'difficulty'),
    rating: ModelJson.requiredInt(json, 'rating'),
    popularity: ModelJson.requiredInt(json, 'popularity'),
    publishedAt: ModelJson.requiredDateTime(json, 'publishedAt'),
    topics: ModelJson.stringList(json, 'topics'),
    content: ModelJson.objectList(json, 'content', LibraryTextPage.fromJson),
    individualPriceInCents: ModelJson.optionalInt(
      json,
      'individualPriceInCents',
    ),
    revenueChannel: json['revenueChannel'] == null
        ? null
        : ModelJson.enumValue(
            LibraryRevenueChannel.values,
            json['revenueChannel'],
            'revenueChannel',
          ),
    fileSizeLabel: ModelJson.optionalString(json, 'fileSizeLabel'),
    isNew: ModelJson.optionalBool(json, 'isNew') ?? false,
    isDownloadable: ModelJson.optionalBool(json, 'isDownloadable') ?? true,
  );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'categoryId': categoryId,
    'description': description,
    'type': type.name,
    'availability': availability.name,
    'format': format.name,
    'language': language,
    'rights': rights.name,
    'rightsHolder': rightsHolder,
    'distributionAuthorized': distributionAuthorized,
    'pages': pages,
    'publisher': publisher,
    'licenseDetails': licenseDetails,
    'difficulty': difficulty,
    'rating': rating,
    'popularity': popularity,
    'publishedAt': publishedAt.toIso8601String(),
    'topics': topics,
    'content': content.map((page) => page.toJson()).toList(),
    'individualPriceInCents': individualPriceInCents,
    'revenueChannel': revenueChannel?.name,
    'fileSizeLabel': fileSizeLabel,
    'isNew': isNew,
    'isDownloadable': isDownloadable,
  };
}

const libraryCategories = <String, String>{
  'informatique': 'Informatique',
  'programmation': 'Programmation',
  'intelligence-artificielle': 'Intelligence artificielle',
  'sciences': 'Sciences',
  'mathematiques': 'Mathématiques',
  'litterature': 'Littérature',
  'histoire': 'Histoire',
  'economie': 'Économie',
  'langues': 'Langues',
  'entrepreneuriat': 'Entrepreneuriat',
  'developpement-personnel': 'Développement personnel',
  'education': 'Éducation',
};
