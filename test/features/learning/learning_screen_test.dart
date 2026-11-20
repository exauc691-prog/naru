import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/core/widgets/app_button.dart';
import 'package:naru/core/providers/theme_provider.dart';
import 'package:naru/features/learning/providers/learning_providers.dart';
import 'package:naru/features/learning/providers/lesson_local_providers.dart';
import 'package:naru/features/learning/presentation/screens/course_catalog_screen.dart';
import 'package:naru/features/learning/presentation/screens/course_detail_screen.dart';
import 'package:naru/features/learning/presentation/screens/learning_screen.dart';
import 'package:naru/features/learning/presentation/screens/learning_path_detail_screen.dart';
import 'package:naru/features/learning/presentation/screens/learning_paths_screen.dart';
import 'package:naru/features/learning/presentation/screens/lesson_reader_screen.dart';
import 'package:naru/features/learning/widgets/learning_search_bar.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';
import 'package:naru/features/subscription/providers/subscription_providers.dart';
import 'package:naru/features/subscription/screens/subscription_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'learning page providers use existing mock progress and new courses',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final inProgress = await container.read(inProgressCoursesProvider.future);
      final newCourses = await container.read(newCoursesProvider.future);

      expect(
        inProgress.map((course) => course.id),
        containsAll([
          'dart-fundamentals',
          'flutter-introduction',
          'flutter-layouts',
        ]),
      );
      expect(newCourses.map((course) => course.id), [
        'flutter-navigation',
        'machine-learning-intro',
        'visual-design-basics',
      ]);
    },
  );

  testWidgets('learning search finds courses by domain on a small screen', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);
    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.dark);

    container.read(appRouterProvider).go(AppRoutes.learning);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(LearningScreen),
        matching: find.text('Apprendre'),
      ),
      findsOneWidget,
    );
    expect(
      Theme.of(tester.element(find.byType(LearningScreen))).brightness,
      Brightness.dark,
    );
    expect(find.text('Explorer les domaines'), findsOneWidget);

    final landingSearch = find.descendant(
      of: find.byType(LearningSearchBar),
      matching: find.byType(TextField),
    );
    await tester.enterText(landingSearch, 'Développement Web');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Recherche'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Créer une page avec HTML et CSS'),
      200,
      scrollable: _screenScrollable(find.byType(CourseCatalogScreen)).first,
    );
    expect(find.text('Créer une page avec HTML et CSS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog filters by domain and level', (tester) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container.read(appRouterProvider).go(AppRoutes.courseCatalogPath());
    await tester.pumpAndSettle();
    expect(find.byType(CourseCatalogScreen), findsOneWidget);

    await tester.tap(find.text('Programmation').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Apprendre Dart de zéro'),
      200,
      scrollable: _screenScrollable(find.byType(CourseCatalogScreen)).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Apprendre Dart de zéro'), findsOneWidget);

    final catalogScroll = _screenScrollable(find.byType(CourseCatalogScreen))
        .first;
    await tester.fling(catalogScroll, const Offset(0, 1000), 2000);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Filtrer'));
    await tester.tap(find.text('Filtrer'));
    await tester.pumpAndSettle();
    final advancedFilter = find.widgetWithText(ChoiceChip, 'Avancé');
    await tester.ensureVisible(advancedFilter);
    await tester.pumpAndSettle();
    await tester.tap(advancedFilter);
    await tester.tap(find.text('Appliquer'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Aucun cours disponible'),
      200,
      scrollable: catalogScroll,
    );
    expect(find.text('Aucun cours disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog applies combined premium and level filters', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container.read(appRouterProvider).go(AppRoutes.courseCatalogPath());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Filtrer'));
    await tester.tap(find.text('Filtrer'));
    await tester.pumpAndSettle();
    final premiumFilter = find.widgetWithText(ChoiceChip, 'Premium');
    final beginnerFilter = find.widgetWithText(ChoiceChip, 'Débutant');
    await tester.ensureVisible(premiumFilter);
    await tester.pumpAndSettle();
    await tester.tap(premiumFilter);
    await tester.ensureVisible(beginnerFilter);
    await tester.pumpAndSettle();
    await tester.tap(beginnerFilter);
    await tester.tap(find.text('Appliquer'));
    await tester.pumpAndSettle();

    expect(find.text('Filtres (2)'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Premium'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Débutant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog applies a learning category and handles empty data', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container
        .read(appRouterProvider)
        .go(AppRoutes.learningCategoryPath('programmation'));
    await tester.pumpAndSettle();
    expect(find.text('Catégorie : Programmation'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Apprendre Dart de zéro'),
      200,
      scrollable: _screenScrollable(find.byType(CourseCatalogScreen)).first,
    );
    expect(find.text('Apprendre Dart de zéro'), findsOneWidget);

    container
        .read(appRouterProvider)
        .go(AppRoutes.learningCategoryPath('entrepreneuriat'));
    await tester.pumpAndSettle();
    expect(find.text('Catégorie : Entrepreneuriat'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Aucun cours disponible'),
      200,
      scrollable: _screenScrollable(find.byType(CourseCatalogScreen)).first,
    );
    expect(find.text('Aucun cours disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('course and learning path actions open their next lesson', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container
        .read(appRouterProvider)
        .go(AppRoutes.courseDetailsPath('dart-fundamentals'));
    await tester.pumpAndSettle();
    expect(find.byType(CourseDetailScreen), findsOneWidget);
    expect(find.text('Apprendre Dart de zéro'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Opérateurs et expressions'),
      200,
      scrollable: _screenScrollable(find.byType(CourseDetailScreen)).first,
    );
    expect(find.text('Opérateurs et expressions'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continuer le cours'),
      240,
      scrollable: _screenScrollable(find.byType(CourseDetailScreen)).first,
    );
    await tester.tap(find.text('Continuer le cours'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonReaderScreen), findsOneWidget);

    container.read(appRouterProvider).go(AppRoutes.learningPaths);
    await tester.pumpAndSettle();
    expect(find.byType(LearningPathsScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Parcours Développeur Flutter débutant'),
      240,
      scrollable: _screenScrollable(find.byType(LearningPathsScreen)).first,
    );
    await tester.tap(find.text('Parcours Développeur Flutter débutant'));
    await tester.pumpAndSettle();
    expect(find.byType(LearningPathDetailScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Modules et leçons'),
      200,
      scrollable: _screenScrollable(find.byType(LearningPathDetailScreen))
          .first,
    );
    expect(find.text('Modules et leçons'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continuer le parcours'),
      240,
      scrollable: _screenScrollable(find.byType(LearningPathDetailScreen))
          .first,
    );
    await tester.tap(find.text('Continuer le parcours'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonReaderScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson reader checks quizzes and saves local notes', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container
        .read(appRouterProvider)
        .go(AppRoutes.lessonDetailsPath('dart-introduction'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonReaderScreen), findsOneWidget);
    expect(find.textContaining('Aucune vidéo réelle'), findsOneWidget);

    final readerScroll = _screenScrollable(find.byType(LessonReaderScreen))
        .first;
    final mainOption = find.widgetWithText(ChoiceChip, 'main');
    await tester.scrollUntilVisible(mainOption, 200, scrollable: readerScroll);
    await tester.pumpAndSettle();
    await tester.tap(mainOption);
    await tester.scrollUntilVisible(
      find.text('Vérifier'),
      200,
      scrollable: readerScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse'), findsOneWidget);

    final noteField = find.byType(TextField).first;
    await tester.ensureVisible(noteField);
    await tester.enterText(noteField, 'Revoir main');
    await tester.pump();
    expect(tester.widget<TextField>(noteField).controller!.text, 'Revoir main');
    final saveButton = find.ancestor(
      of: find.text('Enregistrer la note'),
      matching: find.byType(AppButton),
    );
    expect(tester.widget<AppButton>(saveButton).onPressed, isNotNull);
    await tester.scrollUntilVisible(
      find.text('Enregistrer la note'),
      200,
      scrollable: readerScroll,
    );
    await tester.tap(find.text('Enregistrer la note'));
    await tester.pumpAndSettle();
    expect(
      (await container.read(lessonLocalStoreProvider).load('dart-introduction'))
          .note,
      'Revoir main',
    );
    await tester.scrollUntilVisible(
      find.text('Historique récent'),
      200,
      scrollable: readerScroll,
    );
    expect(find.text('Historique récent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium lessons open subscription settings and save the plan', (
    tester,
  ) async {
    _setSmallScreen(tester);
    final container = await _pumpAuthenticatedApp(tester);
    addTearDown(container.dispose);

    container
        .read(appRouterProvider)
        .go(AppRoutes.lessonDetailsPath('ml-labeled-examples'));
    await tester.pumpAndSettle();
    expect(find.text('Cours Premium'), findsOneWidget);

    await tester.tap(find.text('Découvrir Premium'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Disponible avec Naru Premium'), findsOneWidget);
    await tester.tap(find.text('Découvrir Premium').last);
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionSettingsScreen), findsOneWidget);
    expect(find.text('Votre formule actuelle : Naru Free'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Choisir Standard'),
      200,
      scrollable: _screenScrollable(find.byType(SubscriptionSettingsScreen))
          .first,
    );
    await tester.tap(find.text('Choisir Standard'));
    await tester.pumpAndSettle();

    expect(
      await container.read(subscriptionPlanProvider.future),
      SubscriptionPlan.standard,
    );
    expect(find.text('Votre formule actuelle : Naru Standard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setSmallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<ProviderContainer> _pumpAuthenticatedApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer();
  container.read(authStateProvider.notifier).signInDemo();
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NaruApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _screenScrollable(Finder screen) =>
    find.descendant(of: screen, matching: find.byType(Scrollable));
