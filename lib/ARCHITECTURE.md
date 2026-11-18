# Architecture de Naru

L'application suit une organisation Feature-First : chaque fonctionnalite regroupe
ses donnees, son domaine metier et sa presentation. Les fondations visuelles
generiques sont centralisees dans `core/theme` et `core/widgets`.

## Structure

```text
lib/
├── main.dart                         # Point d'entree Flutter
├── ARCHITECTURE.md
├── app/
│   ├── app.dart                      # Racine MaterialApp
│   ├── app_theme.dart                # ThemeData clair et sombre
│   ├── providers/                    # Injection des repositories et donnees globales
│   │   ├── app_providers.dart
│   │   ├── auth_provider.dart        # Etat d'authentification fictive
│   │   └── repository_providers.dart
│   ├── router/
│   │   ├── app_router.dart           # Routes et redirections centralisees
│   │   └── app_routes.dart           # Chemins de navigation
│   └── navigation/
│       ├── main_navigation.dart      # Navigation inferieure a cinq sections
│       └── temporary_pages.dart
├── core/
│   ├── providers/                    # Etat global partage
│   │   └── theme_provider.dart
│   ├── services/                     # Services transverses
│   │   └── theme_service.dart
│   ├── theme/                        # Tokens visuels du design system
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   └── app_radius.dart
│   ├── widgets/                      # Composants generiques reutilisables
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── app_text_field.dart
│   │   ├── app_progress_bar.dart
│   │   ├── app_empty_state.dart
│   │   ├── app_loading.dart
│   │   ├── app_error_view.dart
│   │   └── section_title.dart
├── data/
│   ├── repositories/                 # Contrats de donnees partages
│   └── mock_repositories/            # Implementations mock en memoire
├── shared/
│   ├── models/                       # Modeles partages entre features
│   │   ├── model_json.dart
│   │   ├── {user, learning_domain, course, learning_path, module, lesson,
│   │   │    exercise, progress, skill_progress, achievement, notification,
│   │   │    ai_message, ai_conversation, daily_goal, learning_activity}_model.dart
│   │   ├── lesson_content_block.dart
│   │   └── enums/
│   │       ├── {difficulty_level, exercise_type, achievement_category,
│   │       │    notification_type, ai_message_sender, ai_message_type,
│   │       │    learning_activity_type, lesson_content_type}.dart
│   └── widgets/                      # Composants reutilisables de haut niveau
└── features/
    └── {auth, onboarding, home, learning, library, learning_paths, lessons, practice,
         progress, ai_assistant, profile, settings}/
        ├── providers/                # Providers Riverpod propres a la feature
        ├── data/
        │   ├── datasources/mock/     # Sources mockees propres a la feature
        │   ├── models/               # Modeles de donnees et de transfert
        │   └── repositories/         # Implementations des repositories
        ├── domain/
        │   ├── entities/             # Objets metier
        │   ├── repositories/         # Contrats des repositories
        │   └── use_cases/            # Cas d'usage
        └── presentation/
            ├── pages/                # Pages de la feature
            ├── widgets/              # Widgets locaux a la feature
            └── controllers/          # Coordination de l'etat et des actions
```

Le sous-arbre `data/domain/presentation` est prevu pour chacune des onze
features. Les repositories transverses sont definis dans `data/repositories/`;
leurs implementations mockees utilisent les donnees de `shared/mock/` et
conservent leurs changements uniquement en memoire. Aucune persistance ni
connexion distante n'est effectuee par ces implementations. `core/` accueille
les services, les tokens visuels et les widgets generiques, sans dependance
envers les features metier.

Riverpod gere les dependances et les donnees asynchrones. `ProviderScope` est
installe au point d'entree, les providers de repositories exposent les contrats
et leurs implementations mockees peuvent etre remplacees par surcharge. Les
`FutureProvider` exposent les etats de chargement, de donnees et d'erreur aux
features sans leur faire instancier les repositories.

GoRouter centralise les routes publiques et protege les destinations de
l'application derriere un etat d'authentification de demonstration. La
navigation inferieure utilise un shell a branches indexees pour conserver
l'etat des cinq sections. Plusieurs pages d'apprentissage et de profil restent
temporaires ; l'onboarding et l'authentification disposent de leurs interfaces.

Les references entre modeles sont conservees sous forme d'identifiants. Les
durees sont serialisees en minutes, les dates en ISO 8601, et les collections
exposees par les modeles sont en lecture seule. Le contenu des lecons utilise
des blocs discrimines par type afin d'accepter de nouveaux formats.

La feature `library` expose son catalogue fictif derriere des providers
remplacables. Les ressources portent des metadonnees de format, de disponibilite
et de droits de distribution, ainsi que des champs reserves aux futures ventes
individuelles et integrations d'editeurs. Le lecteur travaille uniquement sur
du texte original de demonstration. Les favoris, collections, signets, notes,
positions de lecture et telechargements simules sont conserves localement dans
SharedPreferences. Les droits Free, Standard et Premium reutilisent le
gestionnaire central d'abonnements ; aucun fichier distant, paiement ou service
IA n'est connecte.

La feature `ai_assistant` regroupe l'accueil Naru AI, les modes d'apprentissage,
d'aide aux devoirs, de redaction, de programmation, de traduction et
d'organisation, les conversations, l'historique, les outils, les documents et
l'aperçu vocal. Les conversations, exemples de documents, aperçus vocaux et
compteurs de demonstration sont serialises en JSON dans SharedPreferences sous
`naru.ai.assistant.v1`. Les exemples de documents ne contiennent aucun fichier
et ne sont jamais lus ni transmis ; l'interface vocale n'active pas le
microphone et ne genere pas d'audio. Les reponses sont produites localement par
un service de demonstration et sont identifiees comme telles.

Les limites quotidiennes sont centralisees dans `AssistantQuotaConfig` et
restent configurables. Elles sont appliquees avant l'ajout d'un message, sans
effacer le brouillon ni l'historique lorsque la limite est atteinte. Les droits
de modes et d'outils reutilisent `SubscriptionEntitlements`. `AIModelCatalog`
prepare un choix futur selon la formule, la capacite, la complexite et le cout ;
son registre initial est vide et aucun modele fournisseur n'est affiche comme
connecte. Aucune cle, API IA, analyse de document, reconnaissance vocale,
synthese vocale ou fonction de paiement n'est integree.

## Features

- `onboarding` : prise en main et preferences initiales.
- `auth` : interfaces d'inscription, de connexion et de recuperation.
- `home` : accueil et resume de l'activite.
- `learning` : experience generale d'apprentissage.
- `library` : catalogue pedagogique, details, lecteur de demonstration,
  bibliotheque personnelle, collections et telechargements simules.
- `ai_assistant` : conversations locales de demonstration, modes specialises,
  outils, historique filtrable, preparation de documents et apercu vocal sans
  captation ni moteur audio.
- `learning_paths` : parcours et cours.
- `lessons` : contenu et progression des lecons.
- `practice` : exercices et pratique.
- `progress` : progression et statistiques.
- `ai_assistant` : accompagnement par assistant IA.
- `profile` : profil de l'apprenant.
- `settings` : preferences et configuration.

La feature `onboarding` contient l'ecran de bienvenue, trois pages de
presentation navigables et leurs illustrations Flutter natives. Les boutons
terminaux utilisent les routes `onboarding`, `login` et `register` centralisees.

La feature `auth` valide localement les formulaires et expose des actions mock
qui deleguent a l'etat de session de demonstration existant. Les identifiants
saisis ne sont ni transmis ni conserves ; la recuperation affiche une
confirmation de simulation sans envoyer d'e-mail.

La feature `learning` s'appuie sur le repository mock existant pour rechercher
les cours par titre, description, domaine et tags, puis filtrer par domaine et
niveau. Les pages de cours et de parcours derivent objectifs, competences,
modules, lecons et progression des modeles existants. Les actions de debut et
de reprise ouvrent les routes de lecons deja configurees.

La feature `home` compose l'accueil a partir des providers de profil, d'objectif,
de cours recommandes, de domaines et d'activite recente. La reprise derive la
prochaine lecon non terminee depuis l'activite et les relations existantes entre
lecons, modules et parcours. Les destinations de recherche et de domaine
utilisent temporairement la section `learning` ; les details, notifications et
les cinq onglets reutilisent les routes et la navigation existantes.

L'accueil propose egalement une entree vers la bibliotheque numerique, placee
dans la branche `home` du shell afin de conserver les cinq destinations de
navigation inferieure. Le catalogue et les espaces personnels sont des routes
enfants de cette destination.

L'accueil propose egalement une entree vers Naru AI dans la meme branche
`home`, sans ajouter d'onglet a la navigation inferieure. Les ecrans de
conversation, modes, outils, documents, voix, historique et parametres sont des
routes enfants de `/app/home/assistant`.

L'authentification reste fictive et en memoire. Aucune identite, aucun mot de
passe ni aucune donnee de session ne sont persistes ; les services backend
restent hors du perimetre actuel.
