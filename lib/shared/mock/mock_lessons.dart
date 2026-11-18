import '../models/enums/difficulty_level.dart';
import '../models/enums/lesson_format.dart';
import '../models/lesson_content_block.dart';
import '../models/lesson_model.dart';

final mockLessons = List<LessonModel>.unmodifiable([
  _lesson(
    id: 'dart-introduction',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-foundations',
    title: 'Introduction à Dart',
    description:
        'Découvre le rôle de Dart et la forme minimale d’un programme.',
    minutes: 20,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    format: LessonFormat.video,
    completed: true,
    objectives: [
      'Expliquer à quoi sert un langage de programmation.',
      'Repérer le point d’entrée main d’un petit programme.',
    ],
    content: [
      _paragraph(
        'Dart est un langage utilisé notamment avec Flutter. Un programme '
        'décrit des instructions que l’ordinateur exécute dans un ordre défini.',
      ),
      _heading('Le point d’entrée'),
      _code("void main() {\n  print('Bonjour, Naru !');\n}"),
      _example('Lire l’exemple', [
        _paragraph('main est la fonction appelée au démarrage.'),
        _paragraph('print affiche le texte dans la sortie du programme.'),
      ]),
      _important(
        'Commence par lire le programme de haut en bas et identifie '
        'l’instruction qui produit un résultat.',
      ),
    ],
  ),
  _lesson(
    id: 'dart-variables',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-foundations',
    title: 'Variables et valeurs',
    description: 'Nomme une donnée et choisis si sa référence peut changer.',
    minutes: 25,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    format: LessonFormat.illustrated,
    completed: true,
    objectives: [
      'Déclarer une variable avec var.',
      'Distinguer une valeur réassignable de final.',
    ],
    content: [
      _paragraph(
        'Une variable associe un nom à une valeur. Utilise var lorsque le type '
        'peut être déduit et que la variable sera réassignée.',
      ),
      _code("var points = 4;\npoints = 5;\nfinal learner = 'Samira';"),
      _example('Choisir entre var et final', [
        _paragraph('points change : var convient.'),
        _paragraph(
          'learner garde sa référence : final rend cette intention visible.',
        ),
      ]),
      _important(
        'Choisis final par défaut si la variable n’a pas à être réassignée.',
      ),
    ],
  ),
  _lesson(
    id: 'dart-data-types',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-foundations',
    title: 'Types de données',
    description: 'Associe nombres, textes et valeurs logiques à leurs types.',
    minutes: 20,
    order: 3,
    difficulty: DifficultyLevel.beginner,
    format: LessonFormat.document,
    completed: true,
    objectives: [
      'Identifier int, double, String et bool.',
      'Utiliser une interpolation dans une chaîne.',
    ],
    content: [
      _paragraph(
        'Le type décrit les opérations pertinentes pour une valeur. Dart '
        'vérifie ces types pendant l’analyse et la compilation.',
      ),
      _code(
        "int lessons = 3;\ndouble minutes = 12.5;\nString name = 'Samira';\nbool ready = true;",
      ),
      _example('Afficher une valeur', [
        _code("print('\$name a terminé \$lessons leçons.');"),
        _paragraph(
          'Le préfixe \$ insère la valeur d’une expression dans le texte.',
        ),
      ]),
      _important('Un nombre décimal comme 12.5 est un double, pas un int.'),
    ],
  ),
  _lesson(
    id: 'dart-operators',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-foundations',
    title: 'Opérateurs et expressions',
    description: 'Combine des valeurs pour calculer ou comparer un résultat.',
    minutes: 20,
    order: 4,
    difficulty: DifficultyLevel.beginner,
    format: LessonFormat.audio,
    completed: true,
    objectives: [
      'Utiliser des opérateurs arithmétiques.',
      'Construire une comparaison et une condition logique.',
    ],
    content: [
      _paragraph(
        'Les opérateurs arithmétiques calculent une valeur. Les comparaisons '
        'produisent un booléen que tu peux ensuite combiner.',
      ),
      _code(
        'final remaining = 20 - 7;\nfinal hasTime = remaining >= 10;\nfinal canContinue = hasTime && true;',
      ),
      _list([
        '+ additionne',
        '- soustrait',
        '== compare l’égalité',
        '&& combine deux booléens',
      ]),
      _important(
        'Les opérateurs de comparaison renvoient true ou false ; ils ne modifient '
        'pas les valeurs comparées.',
      ),
    ],
  ),
  _lesson(
    id: 'dart-conditions',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-control-flow',
    title: 'Conditions',
    description: 'Choisis les instructions à exécuter selon une condition.',
    minutes: 25,
    order: 5,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Écrire une branche if et une branche else.',
      'Éviter de répéter une condition inutilement.',
    ],
    content: [
      _paragraph(
        'Une condition permet au programme de choisir une branche. Son '
        'expression doit produire un booléen.',
      ),
      _code(
        "final minutesToday = 20;\nif (minutesToday >= 20) {\n  print('Objectif atteint');\n} else {\n  print('Encore un peu de pratique');\n}",
      ),
      _example('Lire le résultat', [
        _paragraph('Avec 20 minutes, la première branche est exécutée.'),
        _paragraph(
          'Si la valeur est inférieure à 20, le programme choisit else.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'dart-loops',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-control-flow',
    title: 'Boucles',
    description: 'Répète des instructions avec for et for-in.',
    minutes: 25,
    order: 6,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Parcourir une suite de nombres avec for.',
      'Choisir for-in pour parcourir les éléments d’une collection.',
    ],
    content: [
      _paragraph(
        'Une boucle évite de recopier la même instruction. Une boucle for '
        'est pratique lorsque le nombre de répétitions est connu.',
      ),
      _code(
        'for (var index = 0; index < 3; index++) {\n  print(index);\n}\n\nfor (final topic in [\'Dart\', \'Flutter\']) {\n  print(topic);\n}',
      ),
      _example('Vérifier la borne', [
        _paragraph('index < 3 produit les valeurs 0, 1 et 2.'),
        _paragraph(
          'La condition devient fausse avant une quatrième répétition.',
        ),
      ]),
      _important(
        'Dans une boucle while, vérifie que la condition pourra devenir fausse.',
      ),
    ],
  ),
  _lesson(
    id: 'dart-functions',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-control-flow',
    title: 'Fonctions',
    description:
        'Regroupe une action réutilisable avec paramètres et résultat.',
    minutes: 30,
    order: 7,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Déclarer une fonction avec un type de retour.',
      'Passer une valeur à un paramètre.',
    ],
    content: [
      _paragraph(
        'Une fonction donne un nom à un traitement. Ses paramètres décrivent '
        'les informations nécessaires et son type de retour décrit le résultat.',
      ),
      _code(
        'int totalMinutes(int lessons, int minutesPerLesson) {\n  return lessons * minutesPerLesson;\n}',
      ),
      _example('Appeler la fonction', [
        _code('final total = totalMinutes(3, 10);'),
        _paragraph(
          'total vaut 30 car la fonction multiplie ses deux arguments.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'dart-lists',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-collections',
    title: 'Listes',
    description: 'Stocke et parcours des éléments dans un ordre défini.',
    minutes: 25,
    order: 8,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Créer une liste typée.',
      'Lire un élément par son index et parcourir la liste.',
    ],
    content: [
      _paragraph(
        'Une List conserve ses éléments dans un ordre. Les index commencent '
        'à zéro et permettent d’accéder à une position précise.',
      ),
      _code(
        "final topics = <String>['Dart', 'Flutter'];\ntopics.add('Widgets');\nfinal firstTopic = topics[0];",
      ),
      _example('Parcourir une liste', [
        _code('for (final topic in topics) {\n  print(topic);\n}'),
        _paragraph(
          'for-in lit chaque élément sans manipuler directement les index.',
        ),
      ]),
      _important(
        'Vérifie qu’une liste n’est pas vide avant de lire son index zéro.',
      ),
    ],
  ),
  _lesson(
    id: 'dart-maps',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-collections',
    title: 'Maps',
    description:
        'Associe des clés à des valeurs pour retrouver une information.',
    minutes: 25,
    order: 9,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Créer une Map avec des types de clé et de valeur.',
      'Lire et mettre à jour une valeur par sa clé.',
    ],
    content: [
      _paragraph(
        'Une Map associe chaque clé à une valeur. Les clés sont uniques ; '
        'elles peuvent représenter, par exemple, le nom d’une leçon.',
      ),
      _code(
        "final scores = <String, int>{'Dart': 8, 'Flutter': 5};\nscores['Dart'] = 9;\nfinal dartScore = scores['Dart'];",
      ),
      _example('Accès prudent', [
        _paragraph('La lecture avec une clé absente renvoie null.'),
        _paragraph(
          'Utilise containsKey ou une valeur par défaut si nécessaire.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'dart-sets',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-collections',
    title: 'Sets',
    description: 'Conserve des valeurs uniques lorsque l’ordre ne compte pas.',
    minutes: 20,
    order: 10,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Créer un Set typé.',
      'Expliquer pourquoi un doublon n’ajoute pas un nouvel élément.',
    ],
    content: [
      _paragraph(
        'Un Set représente un ensemble de valeurs distinctes. Il est utile '
        'pour éliminer des doublons ou tester rapidement une appartenance.',
      ),
      _code(
        "final completedTopics = <String>{'Dart', 'Types', 'Dart'};\nfinal hasTypes = completedTopics.contains('Types');",
      ),
      _example('Compter les valeurs uniques', [
        _paragraph(
          'Le Set ci-dessus ne contient qu’une seule occurrence de Dart.',
        ),
        _paragraph(
          'Ne compte pas sur un ordre d’affichage pour représenter une progression.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'dart-classes',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-objects',
    title: 'Classes',
    description:
        'Décris la structure et les comportements d’un type personnalisé.',
    minutes: 30,
    order: 11,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Déclarer une classe avec des champs.',
      'Créer un constructeur pour initialiser ces champs.',
    ],
    content: [
      _paragraph(
        'Une classe décrit un type. Elle regroupe des données et les opérations '
        'qui ont du sens pour ces données.',
      ),
      _code(
        "class Lesson {\n  Lesson(this.title, this.minutes);\n\n  final String title;\n  final int minutes;\n}",
      ),
      _example('Lire le constructeur', [
        _paragraph(
          'Lesson(this.title, this.minutes) reçoit les valeurs à la création.',
        ),
        _paragraph(
          'Les champs final ne sont pas réassignés après leur initialisation.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'dart-objects',
    courseId: 'dart-fundamentals',
    moduleId: 'module-dart-objects',
    title: 'Objets et instances',
    description:
        'Crée des instances et utilise les champs définis par une classe.',
    minutes: 30,
    order: 12,
    difficulty: DifficultyLevel.beginner,
    objectives: ['Instancier une classe.', 'Lire les propriétés d’un objet.'],
    content: [
      _paragraph(
        'Un objet est une instance d’une classe. Chaque instance porte ses '
        'propres valeurs pour les champs définis par cette classe.',
      ),
      _code(
        "final lesson = Lesson('Variables', 25);\nprint(lesson.title);\nprint(lesson.minutes);",
      ),
      _example('Comparer deux objets', [
        _paragraph(
          'Deux instances de Lesson peuvent avoir des titres différents.',
        ),
        _paragraph(
          'La classe décrit leur forme ; les instances contiennent leurs valeurs.',
        ),
      ]),
      _important(
        'Une classe est un plan ; un objet est une instance créée à partir de ce plan.',
      ),
    ],
  ),
  _lesson(
    id: 'flutter-intro-concepts',
    courseId: 'flutter-introduction',
    moduleId: 'module-flutter-foundations',
    title: 'Flutter et les widgets',
    description:
        'Découvre l’arbre de widgets qui décrit l’interface d’une application.',
    minutes: 25,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    completed: true,
    objectives: [
      'Expliquer le rôle d’un widget.',
      'Repérer le widget racine d’une petite application.',
    ],
    content: [
      _paragraph(
        'Flutter construit l’interface à partir de widgets. Un widget décrit '
        'une partie de l’interface et peut contenir d’autres widgets.',
      ),
      _code(
        'MaterialApp(\n  home: Scaffold(\n    body: Center(\n      child: Text(\'Bonjour\'),\n    ),\n  ),\n)',
        language: 'dart',
      ),
      _important(
        'Les widgets décrivent l’interface ; ils ne sont pas des images capturées.',
      ),
    ],
  ),
  _lesson(
    id: 'flutter-build-cycle',
    courseId: 'flutter-introduction',
    moduleId: 'module-flutter-foundations',
    title: 'Le cycle de construction',
    description: 'Comprends pourquoi Flutter peut reconstruire un widget plusieurs fois.',
    minutes: 25,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Identifier la méthode build.',
      'Éviter les effets de bord dans build.',
    ],
    content: [
      _paragraph(
        'La méthode build décrit le widget à afficher pour l’état courant. '
        'Flutter peut la rappeler lorsqu’un état ou une dépendance change.',
      ),
      _example('Séparer description et action', [
        _paragraph(
          'Garde build déterministe et sans écriture de fichier ou requête.',
        ),
        _paragraph(
          'Déclenche une action depuis un callback ou une couche dédiée.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'flutter-widget-layouts',
    courseId: 'flutter-layouts',
    moduleId: 'module-flutter-foundations',
    title: 'Composer une mise en page',
    description: 'Dispose des widgets avec des compositions adaptées aux écrans mobiles.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Choisir entre Row et Column.',
      'Utiliser Expanded pour partager l’espace disponible.',
    ],
    content: [
      _paragraph(
        'Row place ses enfants horizontalement et Column verticalement. '
        'Les contraintes du parent déterminent la place dont ils disposent.',
      ),
      _code(
        'Column(\n  children: [\n    Text(\'Titre\'),\n    Expanded(child: ListView()),\n  ],\n)',
        language: 'dart',
      ),
      _important(
        'Sur téléphone, vérifie les contraintes et le défilement lorsque le contenu '
        'dépasse la hauteur disponible.',
      ),
    ],
  ),
  _lesson(
    id: 'flutter-navigation-basics',
    courseId: 'flutter-navigation',
    moduleId: 'module-flutter-navigation-state',
    title: 'Navigation et retour',
    description:
        'Comprends la pile de navigation et le rôle de l’action retour.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.intermediate,
    objectives: [
      'Expliquer le principe d’une pile d’écrans.',
      'Identifier les données à transmettre lors d’une navigation.',
    ],
    content: [
      _paragraph(
        'La navigation ajoute ou remplace une destination. L’action retour '
        'retire généralement la destination courante de la pile.',
      ),
      _example('Transmettre une référence', [
        _paragraph(
          'Transmets un identifiant de cours plutôt qu’une copie de tout le catalogue.',
        ),
        _paragraph(
          'La destination peut ensuite retrouver le cours dans un repository.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'flutter-state-local',
    courseId: 'flutter-state',
    moduleId: 'module-flutter-navigation-state',
    title: 'État local et état partagé',
    description:
        'Choisis où conserver une valeur selon les widgets qui en dépendent.',
    minutes: 35,
    order: 1,
    difficulty: DifficultyLevel.intermediate,
    objectives: [
      'Reconnaître un état temporaire propre à un widget.',
      'Repérer quand plusieurs fonctionnalités ont besoin du même état.',
    ],
    content: [
      _paragraph(
        'Un état local peut rester dans un StatefulWidget. Un choix de thème '
        'ou une session partagée doit être exposé à une portée plus large.',
      ),
      _example('Choisir une portée', [
        _paragraph('La valeur d’un champ ouvert est souvent locale.'),
        _paragraph(
          'La préférence de thème de Naru est partagée et persistée séparément.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'python-first-script',
    courseId: 'python-foundations',
    moduleId: 'module-python-foundations',
    title: 'Écrire un premier script Python',
    description: 'Lis une suite d’instructions et affiche un résultat simple.',
    minutes: 25,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Repérer une instruction d’affichage.',
      'Utiliser une variable pour nommer une valeur.',
    ],
    content: [
      _paragraph(
        'Python exécute les instructions du script. L’indentation est '
        'significative dans les blocs et doit rester cohérente.',
      ),
      _code(
        "learner = 'Samira'\nlessons = 2\nprint(f'{learner} a commencé {lessons} leçons.')",
        language: 'python',
      ),
      _important(
        'Une indentation régulière rend la structure du script lisible.',
      ),
    ],
  ),
  _lesson(
    id: 'python-control-flow',
    courseId: 'python-foundations',
    moduleId: 'module-python-foundations',
    title: 'Conditions et répétitions en Python',
    description: 'Choisis une branche et parcours une séquence.',
    minutes: 30,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Écrire une condition if/else.',
      'Parcourir une séquence avec for.',
    ],
    content: [
      _paragraph(
        'Une condition sélectionne un bloc selon un booléen. La boucle for '
        'parcourt les éléments d’une séquence.',
      ),
      _code(
        'for topic in [\'types\', \'fonctions\']:\n    if topic:\n        print(topic)',
        language: 'python',
      ),
    ],
  ),
  _lesson(
    id: 'git-commits',
    courseId: 'git-basics',
    moduleId: 'module-git-basics',
    title: 'Créer un commit clair',
    description:
        'Prépare un changement puis enregistre un point de l’historique.',
    minutes: 45,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Distinguer le répertoire de travail de l’index.',
      'Rédiger un message de commit décrivant une modification.',
    ],
    content: [
      _paragraph(
        'Git permet de suivre les changements. L’index sélectionne les '
        'modifications qui entreront dans le prochain commit.',
      ),
      _code(
        'git status\ngit add lib/example.dart\ngit commit -m "Add lesson model"',
        language: 'shell',
      ),
      _important('Vérifie git status avant de créer un commit.'),
    ],
  ),
  _lesson(
    id: 'html-document-structure',
    courseId: 'html-css-foundations',
    moduleId: 'module-web-structure',
    title: 'Structurer un document HTML',
    description: 'Organise un contenu avec des éléments adaptés à leur rôle.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Distinguer un titre d’un paragraphe.',
      'Utiliser une structure sémantique simple.',
    ],
    content: [
      _paragraph(
        'HTML décrit la structure et le sens du contenu. Utilise les éléments '
        'de titre selon la hiérarchie, pas seulement pour leur apparence.',
      ),
      _code(
        '<main>\n  <h1>Mon carnet</h1>\n  <p>Une note de lecture.</p>\n</main>',
        language: 'html',
      ),
      _important(
        'Un titre principal unique aide à comprendre l’organisation de la page.',
      ),
    ],
  ),
  _lesson(
    id: 'css-layout',
    courseId: 'html-css-foundations',
    moduleId: 'module-web-structure',
    title: 'Espacement et boîte CSS',
    description: 'Comprends contenu, bordure, marge et espacement intérieur.',
    minutes: 35,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Distinguer padding et margin.',
      'Repérer les propriétés de base d’une règle CSS.',
    ],
    content: [
      _paragraph(
        'Le modèle de boîte CSS sépare le contenu, le padding, la bordure et '
        'la marge. Ces notions expliquent l’espace occupé par un élément.',
      ),
      _code(
        '.card {\n  padding: 16px;\n  margin-block: 12px;\n  border: 1px solid;\n}',
        language: 'css',
      ),
    ],
  ),
  _lesson(
    id: 'js-values-functions',
    courseId: 'javascript-basics',
    moduleId: 'module-web-javascript',
    title: 'Valeurs et fonctions JavaScript',
    description: 'Nomme des valeurs et regroupe une action dans une fonction.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Déclarer une constante avec const.',
      'Appeler une fonction avec un argument.',
    ],
    content: [
      _paragraph(
        'const nomme une liaison qui ne sera pas réassignée. Une fonction '
        'peut recevoir des arguments et produire un résultat.',
      ),
      _code(
        'const minutes = 20;\nfunction greet(name) {\n  return `Bonjour, \${name}`;\n}',
        language: 'javascript',
      ),
    ],
  ),
  _lesson(
    id: 'js-dom-events',
    courseId: 'javascript-basics',
    moduleId: 'module-web-javascript',
    title: 'Réagir à un événement',
    description: 'Relie une action utilisateur à un traitement JavaScript.',
    minutes: 30,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Expliquer le rôle d’un gestionnaire d’événement.',
      'Séparer l’action de l’affichage du résultat.',
    ],
    content: [
      _paragraph(
        'Un événement représente une action telle qu’un clic. Un gestionnaire '
        'réagit à cette action et peut mettre à jour une partie de la page.',
      ),
      _example('Penser à l’accessibilité', [
        _paragraph('Un contrôle interactif doit rester utilisable au clavier.'),
        _paragraph('Choisis un élément HTML qui exprime déjà le rôle attendu.'),
      ]),
    ],
  ),
  _lesson(
    id: 'web-accessibility-basics',
    courseId: 'web-accessibility',
    moduleId: 'module-web-structure',
    title: 'Premiers réflexes d’accessibilité',
    description: 'Rends une page plus compréhensible au clavier et avec un lecteur d’écran.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Décrire une image informative avec un texte alternatif.',
      'Respecter une hiérarchie de titres.',
    ],
    content: [
      _paragraph(
        'Une interface accessible rend l’information perceptible et les '
        'actions utilisables par des personnes aux besoins variés.',
      ),
      _list([
        'Donne un nom explicite aux contrôles.',
        'Garde un contraste lisible.',
        'Vérifie l’ordre de navigation au clavier.',
      ]),
      _important(
        'Le texte alternatif décrit la fonction ou l’information utile de l’image.',
      ),
    ],
  ),
  _lesson(
    id: 'ai-what-is-model',
    courseId: 'ai-foundations',
    moduleId: 'module-ai-foundations',
    title: 'Qu’est-ce qu’un modèle d’IA ?',
    description: 'Distingue modèle, données d’entrée et résultat produit.',
    minutes: 30,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Décrire le rôle d’un modèle.',
      'Identifier une entrée et une sortie dans un exemple.',
    ],
    content: [
      _paragraph(
        'Un modèle transforme une entrée en résultat selon des paramètres '
        'appris ou configurés. Le résultat dépend aussi des données fournies.',
      ),
      _example('Classer un message', [
        _paragraph('Entrée : le texte d’un message.'),
        _paragraph(
          'Sortie possible : une catégorie estimée, pas une certitude.',
        ),
      ]),
      _important(
        'Un résultat plausible n’est pas automatiquement exact ou vérifié.',
      ),
    ],
  ),
  _lesson(
    id: 'ai-training-data',
    courseId: 'ai-foundations',
    moduleId: 'module-ai-foundations',
    title: 'Données et exemples',
    description: 'Comprends comment les exemples influencent un modèle.',
    minutes: 30,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Expliquer le rôle d’exemples d’entraînement.',
      'Repérer un risque de représentation incomplète.',
    ],
    content: [
      _paragraph(
        'Les données d’entraînement fournissent des exemples. Si elles sont '
        'incomplètes ou déséquilibrées, les résultats peuvent l’être aussi.',
      ),
      _example('Interpréter une limite', [
        _paragraph('Un système entraîné sur peu de cas peut mal généraliser.'),
        _paragraph(
          'Demande quelles personnes et situations sont absentes des exemples.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'ai-verify-results',
    courseId: 'responsible-ai',
    moduleId: 'module-ai-responsible-use',
    title: 'Vérifier une réponse générée',
    description: 'Utilise une réponse d’IA comme point de départ à contrôler.',
    minutes: 45,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Vérifier une affirmation importante avec une source indépendante.',
      'Éviter de transmettre des données personnelles inutiles.',
    ],
    content: [
      _paragraph(
        'Une réponse générée peut contenir une erreur formulée avec assurance. '
        'Pour une décision importante, vérifie les faits avec une source fiable.',
      ),
      _list([
        'Repère les affirmations vérifiables.',
        'Compare-les à une source de référence.',
        'Retire les données personnelles non nécessaires.',
      ]),
    ],
  ),
  _lesson(
    id: 'ml-labeled-examples',
    courseId: 'machine-learning-intro',
    moduleId: 'module-ai-machine-learning',
    title: 'Apprendre à partir d’exemples étiquetés',
    description: 'Visualise le principe d’un apprentissage supervisé.',
    minutes: 45,
    order: 1,
    difficulty: DifficultyLevel.intermediate,
    objectives: [
      'Distinguer exemple et étiquette.',
      'Comprendre pourquoi il faut évaluer le modèle sur d’autres exemples.',
    ],
    content: [
      _paragraph(
        'Dans un apprentissage supervisé, chaque exemple est associé à une '
        'étiquette attendue. Le modèle apprend une relation à partir de ces cas.',
      ),
      _example('Trier des fruits', [
        _paragraph('Des mesures simples servent d’entrées.'),
        _paragraph('Une étiquette indique la catégorie à prédire.'),
        _paragraph('Des exemples séparés servent à vérifier les prédictions.'),
      ]),
    ],
  ),
  _lesson(
    id: 'cyber-account-safety',
    courseId: 'cybersecurity-fundamentals',
    moduleId: 'module-cybersecurity-basics',
    title: 'Protéger ses comptes',
    description: 'Renforce l’accès à tes comptes avec des habitudes simples.',
    minutes: 60,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Expliquer l’intérêt d’un mot de passe unique.',
      'Reconnaître un message qui demande une action urgente inhabituelle.',
    ],
    content: [
      _paragraph(
        'Un mot de passe réutilisé relie plusieurs comptes au même secret. '
        'Un gestionnaire peut aider à conserver des mots de passe distincts.',
      ),
      _list([
        'Active l’authentification multifacteur lorsqu’elle est disponible.',
        'Vérifie l’expéditeur avant de suivre une demande urgente.',
        'Ne partage pas de code de connexion reçu par message.',
      ]),
      _important(
        'En cas de doute, ouvre le service depuis son application habituelle.',
      ),
    ],
  ),
  _lesson(
    id: 'database-table-relations',
    courseId: 'database-concepts',
    moduleId: 'module-database-concepts',
    title: 'Tables et relations',
    description: 'Organise des informations sans recopier inutilement les mêmes données.',
    minutes: 60,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Identifier ligne, colonne et clé.',
      'Expliquer comment un identifiant relie deux tables.',
    ],
    content: [
      _paragraph(
        'Une table regroupe des lignes décrites par des colonnes. Une clé '
        'identifie une ligne ; une autre table peut conserver cette clé comme référence.',
      ),
      _example('Cours et leçons', [
        _paragraph('La table Course possède un identifiant de cours.'),
        _paragraph('Chaque ligne de Lesson peut référencer cet identifiant.'),
      ]),
      _important(
        'Une référence par identifiant évite de dupliquer tout l’objet lié.',
      ),
    ],
  ),
  _lesson(
    id: 'sql-select',
    courseId: 'sql-for-beginners',
    moduleId: 'module-sql-queries',
    title: 'Sélectionner des colonnes avec SQL',
    description: 'Écris une requête qui ne récupère que les champs utiles.',
    minutes: 40,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Lire une requête SELECT ... FROM.',
      'Choisir explicitement les colonnes utiles.',
    ],
    content: [
      _paragraph(
        'SELECT indique les colonnes demandées et FROM la table consultée. '
        'Lister les colonnes rend l’intention plus claire que sélectionner tout.',
      ),
      _code('SELECT title, difficulty\nFROM courses;', language: 'sql'),
    ],
  ),
  _lesson(
    id: 'sql-filter-sort',
    courseId: 'sql-for-beginners',
    moduleId: 'module-sql-queries',
    title: 'Filtrer et trier des résultats',
    description: 'Réduis les lignes avec WHERE et organise-les avec ORDER BY.',
    minutes: 50,
    order: 2,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Ajouter une condition avec WHERE.',
      'Trier des résultats de manière explicite.',
    ],
    content: [
      _paragraph(
        'WHERE filtre les lignes selon une condition. ORDER BY organise le '
        'résultat ; la direction peut être croissante ou décroissante.',
      ),
      _code(
        "SELECT title, rating\nFROM courses\nWHERE difficulty = 'beginner'\nORDER BY rating DESC;",
        language: 'sql',
      ),
      _important(
        'Une requête qui trie les résultats doit nommer son critère de tri.',
      ),
    ],
  ),
  _lesson(
    id: 'algorithm-decomposition',
    courseId: 'algorithmic-thinking',
    moduleId: 'module-algorithmic-thinking',
    title: 'Décomposer un problème',
    description: 'Transforme une consigne en étapes observables et testables.',
    minutes: 75,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    completed: true,
    objectives: [
      'Définir les entrées et le résultat attendu.',
      'Écrire des étapes dans un ordre vérifiable.',
    ],
    content: [
      _paragraph(
        'Avant de coder, reformule le problème. Identifie les données reçues '
        'et le résultat qui permettra de vérifier la solution.',
      ),
      _list([
        'Lire la liste des durées.',
        'Additionner les valeurs.',
        'Comparer le total à l’objectif.',
        'Afficher si l’objectif est atteint.',
      ], ordered: true),
      _important('Teste aussi un cas vide et une valeur située à la limite.'),
    ],
  ),
  _lesson(
    id: 'logic-statements',
    courseId: 'mathematical-logic',
    moduleId: 'module-mathematical-logic',
    title: 'Propositions et conclusions',
    description: 'Distingue une proposition vérifiable d’une opinion.',
    minutes: 45,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Reconnaître une proposition vraie ou fausse.',
      'Vérifier une conclusion à partir de ses conditions.',
    ],
    content: [
      _paragraph(
        'Une proposition possède une valeur de vérité. Une conclusion logique '
        'doit découler des prémisses, pas seulement sembler plausible.',
      ),
      _example('Tester une condition', [
        _paragraph(
          'Si toutes les leçons terminées sont comptées, leur total ne dépasse pas le total disponible.',
        ),
        _paragraph(
          'Un seul contre-exemple suffit à invalider une affirmation générale.',
        ),
      ]),
    ],
  ),
  _lesson(
    id: 'technical-english-docs',
    courseId: 'technical-english',
    moduleId: 'module-technical-english',
    title: 'Lire une documentation technique',
    description:
        'Repère les verbes d’action et les exemples dans une consigne.',
    minutes: 60,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Reconnaître des verbes fréquents comme create et return.',
      'Utiliser un exemple pour déduire le sens d’un terme.',
    ],
    content: [
      _paragraph(
        'Dans une documentation, les titres et les extraits de code donnent '
        'souvent le contexte nécessaire pour comprendre un mot nouveau.',
      ),
      _list([
        'create : créer',
        'return : renvoyer une valeur',
        'required : obligatoire',
        'optional : facultatif',
      ]),
      _important(
        'Vérifie le sens dans la phrase complète avant de mémoriser un terme.',
      ),
    ],
  ),
  _lesson(
    id: 'scientific-measurements',
    courseId: 'scientific-data',
    moduleId: 'module-scientific-data',
    title: 'Lire des mesures scientifiques',
    description: 'Observe une série de mesures en tenant compte des unités.',
    minutes: 60,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Lire une valeur avec son unité.',
      'Décrire une tendance sans confondre corrélation et causalité.',
    ],
    content: [
      _paragraph(
        'Une mesure n’a de sens qu’avec son unité et son contexte. Une série '
        'peut révéler une tendance sans expliquer à elle seule sa cause.',
      ),
      _example('Comparer deux jours', [
        _paragraph('Note les unités et la période de chaque mesure.'),
        _paragraph('Décris ce qui varie avant de proposer une explication.'),
      ]),
    ],
  ),
  _lesson(
    id: 'spreadsheet-formulas',
    courseId: 'spreadsheet-skills',
    moduleId: 'module-spreadsheet-skills',
    title: 'Formules et références de cellules',
    description: 'Calcule un total et comprends comment une formule référence les cellules.',
    minutes: 45,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Écrire une formule qui commence par =.',
      'Utiliser une fonction de somme sur une plage.',
    ],
    content: [
      _paragraph(
        'Une formule commence par le signe égal. Une référence de cellule '
        'permet à la formule de suivre la valeur qui s’y trouve.',
      ),
      _code('=SUM(B2:B6)', language: 'spreadsheet'),
      _important(
        'Vérifie la plage sélectionnée pour ne pas oublier ou compter deux fois une ligne.',
      ),
    ],
  ),
  _lesson(
    id: 'visual-hierarchy',
    courseId: 'visual-design-basics',
    moduleId: 'module-visual-design',
    title: 'Créer une hiérarchie visuelle',
    description:
        'Guide le regard avec contraste, alignement et niveaux de texte.',
    minutes: 60,
    order: 1,
    difficulty: DifficultyLevel.beginner,
    objectives: [
      'Identifier l’information principale d’un visuel.',
      'Utiliser l’espacement et le contraste sans multiplier les styles.',
    ],
    content: [
      _paragraph(
        'Une hiérarchie visuelle aide à comprendre quoi lire en premier. '
        'La taille, le contraste et l’espacement doivent soutenir le sens.',
      ),
      _list([
        'Donne une place nette au titre.',
        'Regroupe les éléments qui vont ensemble.',
        'Vérifie la lisibilité à petite taille.',
      ]),
    ],
  ),
]);

LessonModel _lesson({
  required String id,
  required String courseId,
  required String moduleId,
  required String title,
  required String description,
  required int minutes,
  required int order,
  required DifficultyLevel difficulty,
  LessonFormat format = LessonFormat.text,
  required List<String> objectives,
  required List<LessonContentBlock> content,
  bool completed = false,
}) => LessonModel(
  id: id,
  courseId: courseId,
  moduleId: moduleId,
  title: title,
  description: description,
  content: content,
  objectives: objectives,
  estimatedDuration: Duration(minutes: minutes),
  order: order,
  difficulty: difficulty,
  isCompleted: completed,
  format: format,
);

LessonParagraphBlock _paragraph(String text) =>
    LessonParagraphBlock(text: text);

LessonHeadingBlock _heading(String text, {int level = 2}) =>
    LessonHeadingBlock(text: text, level: level);

LessonListBlock _list(List<String> items, {bool ordered = false}) =>
    LessonListBlock(items: items, ordered: ordered);

LessonCodeBlock _code(String code, {String? language = 'dart'}) =>
    LessonCodeBlock(code: code, language: language);

LessonExampleBlock _example(String title, List<LessonContentBlock> content) =>
    LessonExampleBlock(title: title, content: content);

LessonImportantPointBlock _important(String text) =>
    LessonImportantPointBlock(text: text);
