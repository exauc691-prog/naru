import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('password recovery returns to the login route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();

    container.read(appRouterProvider).go(AppRoutes.forgotPassword);
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);

    await tester.tap(find.text('Retour à la connexion'));
    await tester.pumpAndSettle();
    expect(find.text('Bon retour parmi nous'), findsOneWidget);
  });

  testWidgets('demo sign-in returns to a protected route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();

    container
        .read(appRouterProvider)
        .go(AppRoutes.courseDetailsPath('dart-fundamentals'));
    await tester.pumpAndSettle();
    expect(find.text('Bon retour parmi nous'), findsOneWidget);

    final emailField = find.byType(TextFormField).at(0);
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'demo@naru.app');
    final passwordField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'demo-password');
    final submitButton = find.text('Se connecter');
    await tester.ensureVisible(submitButton);
    await tester.tap(find.text('Se connecter'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Détail du cours'), findsOneWidget);
    expect(find.text('Apprendre Dart de zéro'), findsOneWidget);
    expect(find.text('Objectifs pédagogiques'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('five navigation branches retain their current route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authStateProvider.notifier).signInDemo();

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      ),
      findsNWidgets(5),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Apprendre'),
      ),
    );
    await tester.pumpAndSettle();
    container
        .read(appRouterProvider)
        .go(AppRoutes.courseDetailsPath('dart-fundamentals'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pratique'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Écran temporaire des exercices.'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Apprendre'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Détail du cours'), findsOneWidget);
  });

  testWidgets('secondary routes and unknown paths are handled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authStateProvider.notifier).signInDemo();

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();

    final routes = <(String, String)>[
      (AppRoutes.courseDetailsPath('course-1'), 'Détail du cours'),
      (AppRoutes.learningPathDetailsPath('path-1'), 'Détail du parcours'),
      (AppRoutes.moduleDetailsPath('module-1'), 'Détail du module'),
      (AppRoutes.lessonDetailsPath('lesson-1'), 'Leçon introuvable'),
      (AppRoutes.exerciseDetailsPath('exercise-1'), 'Détail de l’exercice'),
      (AppRoutes.exerciseResultsPath('exercise-1'), 'Résultat de l’exercice'),
      (AppRoutes.assistant, 'Votre assistant intelligent'),
      (AppRoutes.assistantModes, 'Modes de Naru AI'),
      (
        AppRoutes.assistantModePath('learn'),
        'Progressez avec des explications et des exemples adaptés.',
      ),
      (AppRoutes.assistantDocuments, 'Documents'),
      (AppRoutes.assistantVoice, 'Assistant vocal'),
      (AppRoutes.assistantHistory, 'Historique'),
      (AppRoutes.assistantTools, 'Outils intelligents'),
      (AppRoutes.assistantToolPath('summary'), 'Générateur de résumés'),
      (AppRoutes.assistantSettings, 'Paramètres de Naru AI'),
      (AppRoutes.notifications, 'Notifications'),
      (AppRoutes.settings, 'Formule Naru'),
      (AppRoutes.editProfile, 'Modifier le profil'),
      (AppRoutes.achievements, 'Badges et récompenses'),
    ];

    for (final (location, title) in routes) {
      container.read(appRouterProvider).go(location);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: location);
    }

    container.read(appRouterProvider).go('/unknown-route');
    await tester.pumpAndSettle();
    expect(find.text('Page introuvable'), findsOneWidget);
  });
}
