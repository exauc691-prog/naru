import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/features/library/screens/library_catalog_screen.dart';
import 'package:naru/features/library/screens/library_collections_screen.dart';
import 'package:naru/features/library/screens/library_downloads_screen.dart';
import 'package:naru/features/library/screens/library_home_screen.dart';
import 'package:naru/features/library/screens/library_reader_screen.dart';
import 'package:naru/features/library/screens/library_resource_detail_screen.dart';
import 'package:naru/features/library/screens/my_library_screen.dart';
import 'package:naru/features/library/providers/library_providers.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';
import 'package:naru/features/subscription/providers/subscription_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home exposes the digital library entry point', (tester) async {
    await _pumpAtRoute(tester, AppRoutes.home);

    await tester.tap(find.text('Bibliothèque numérique'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryHomeScreen), findsOneWidget);
    final homeScroll = _screenScrollable(find.byType(LibraryHomeScreen)).first;
    await tester.scrollUntilVisible(
      find.text('Explorer les catégories'),
      200,
      scrollable: homeScroll,
    );
    expect(find.text('Explorer les catégories'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Livres recommandés'),
      200,
      scrollable: homeScroll,
    );
    expect(find.text('Livres recommandés'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search opens a free resource and reader saves progress', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.library);

    final homeSearch = find.byType(TextField).first;
    await tester.enterText(homeSearch, 'algorithmique');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byType(LibraryCatalogScreen), findsOneWidget);
    expect(find.text('Premiers repères en algorithmique'), findsOneWidget);

    await tester.tap(find.text('Premiers repères en algorithmique'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryResourceDetailScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ce que vous allez découvrir'),
      200,
      scrollable: _screenScrollable(find.byType(LibraryResourceDetailScreen))
          .first,
    );
    expect(find.text('Ce que vous allez découvrir'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Lire maintenant'),
      200,
      scrollable: _screenScrollable(find.byType(LibraryResourceDetailScreen))
          .first,
    );
    await tester.tap(find.text('Lire maintenant'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryReaderScreen), findsOneWidget);
    expect(find.text('Page 1 sur 3'), findsOneWidget);

    await tester.tap(find.text('Suivante'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 sur 3'), findsOneWidget);
    expect(
      (await container.read(libraryLocalStoreProvider).load())
          .readingPages['repere-algorithmique'],
      1,
    );

    await tester.tap(find.byTooltip('Ajouter un signet'));
    await tester.pumpAndSettle();
    expect(
      (await container.read(libraryLocalStoreProvider).load())
          .bookmarks['repere-algorithmique'],
      [1],
    );

    await tester.tap(find.byTooltip('Options de lecture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prendre une note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Relire cet exemple');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(
      (await container.read(libraryLocalStoreProvider).load())
          .notes['repere-algorithmique'],
      'Relire cet exemple',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium resource explains access and opens plan selector', (
    tester,
  ) async {
    final container = await _pumpAtRoute(
      tester,
      AppRoutes.libraryResourcePath('ia-responsable'),
    );

    await tester.scrollUntilVisible(
      find.text('Lire maintenant'),
      200,
      scrollable: _screenScrollable(find.byType(LibraryResourceDetailScreen))
          .first,
    );
    await tester.tap(find.text('Lire maintenant'));
    await tester.pumpAndSettle();
    expect(find.text('Bibliothèque Premium'), findsWidgets);
    expect(find.textContaining('10 \$'), findsOneWidget);
    expect(find.text('Avantages inclus :'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'affichage de la fenêtre');

    await tester.tap(find.text('Découvrir Premium').last);
    await tester.pumpAndSettle();
    expect(
      await container.read(subscriptionPlanProvider.future),
      SubscriptionPlan.free,
    );
    expect(find.text('Formule Naru'), findsOneWidget);
    final exception = tester.takeException();
    expect(exception, isNull, reason: '$exception');
  });

  testWidgets('collections can be created, filled, renamed, and deleted', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.libraryCollections);

    await tester.tap(find.byTooltip('Créer une collection'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Révisions Dart');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryCollectionsScreen), findsOneWidget);
    expect(find.text('Révisions Dart'), findsOneWidget);

    await tester.tap(find.text('Ajouter des ressources'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryCatalogScreen), findsOneWidget);
    await tester.tap(find.text('Premiers repères en algorithmique'));
    await tester.pumpAndSettle();
    expect(
      (await container.read(libraryLocalStoreProvider).load())
          .collections
          .single
          .resourceIds,
      ['repere-algorithmique'],
    );

    await tester.tap(find.byTooltip('Retour à la bibliothèque'));
    await tester.pumpAndSettle();
    expect(find.text('Premiers repères en algorithmique'), findsOneWidget);
    await tester.tap(find.byTooltip('Retirer de la collection'));
    await tester.pumpAndSettle();
    expect(find.text('Cette collection est vide'), findsOneWidget);

    await tester.tap(find.byTooltip('Options de la collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Renommer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mon programme');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Mon programme'), findsOneWidget);

    await tester.tap(find.byTooltip('Options de la collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune collection pour le moment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('personal library and simulated downloads can be managed', (
    tester,
  ) async {
    final container = await _pumpAtRoute(
      tester,
      AppRoutes.libraryResourcePath('repere-algorithmique'),
    );

    final detailsScroll = _screenScrollable(
      find.byType(LibraryResourceDetailScreen),
    ).first;
    await tester.scrollUntilVisible(
      find.text('Ajouter à ma bibliothèque'),
      200,
      scrollable: detailsScroll,
    );
    await tester.tap(find.text('Ajouter à ma bibliothèque'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ajouter aux favoris'),
      200,
      scrollable: detailsScroll,
    );
    await tester.tap(find.text('Ajouter aux favoris'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Télécharger'),
      200,
      scrollable: detailsScroll,
    );
    await tester.tap(find.text('Télécharger'));
    await tester.pumpAndSettle();

    expect(
      (await container.read(libraryLocalStoreProvider).load()).downloadedIds,
      contains('repere-algorithmique'),
    );
    container.read(appRouterProvider).go(AppRoutes.myLibrary);
    await tester.pumpAndSettle();
    expect(find.byType(MyLibraryScreen), findsOneWidget);
    expect(find.text('Premiers repères en algorithmique'), findsOneWidget);
    final favoritesFilter = find.widgetWithText(ChoiceChip, 'Favoris');
    await tester.ensureVisible(favoritesFilter);
    await tester.pumpAndSettle();
    await tester.tap(favoritesFilter);
    await tester.pumpAndSettle();
    expect(find.text('Premiers repères en algorithmique'), findsOneWidget);

    container.read(appRouterProvider).go(AppRoutes.libraryDownloads);
    await tester.pumpAndSettle();
    expect(find.byType(LibraryDownloadsScreen), findsOneWidget);
    expect(find.textContaining('simulé'), findsWidgets);
    await tester.tap(find.byTooltip('Retirer le téléchargement simulé'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun téléchargement simulé'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<ProviderContainer> _pumpAtRoute(
  WidgetTester tester,
  String location,
) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(authStateProvider.notifier).signInDemo();
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NaruApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

Finder _screenScrollable(Finder screen) =>
    find.descendant(of: screen, matching: find.byType(Scrollable));
