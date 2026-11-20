import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/core/providers/theme_provider.dart';
import 'package:naru/features/home/providers/home_providers.dart';
import 'package:naru/features/learning/presentation/screens/lesson_reader_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('continue learning points to the next unfinished lesson', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final item = await container.read(continueLearningProvider.future);

    expect(item?.course.id, 'dart-fundamentals');
    expect(item?.lesson, isNotNull);
    expect(item!.lesson!.isCompleted, isFalse);
    expect(item.progress, 4 / 12);
  });

  testWidgets('home fits a small dark screen and its search navigates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authStateProvider.notifier).signInDemo();
    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.dark);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour, Samira'), findsOneWidget);
    expect(find.text('Votre objectif du jour'), findsOneWidget);
    expect(find.text('Objectif atteint aujourd’hui'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    final homeScrollable = find.descendant(
      of: find.byType(ListView).first,
      matching: find.byType(Scrollable),
    );
    await tester.enterText(find.byType(TextField), 'Dart');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Recherche'), findsOneWidget);
    expect(find.text('Apprendre Dart de zéro'), findsOneWidget);
    expect(tester.takeException(), isNull);

    container.read(appRouterProvider).go(AppRoutes.home);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Apprendre Dart de zéro'),
      200,
      scrollable: homeScrollable.first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Apprendre Dart de zéro'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Continuer'),
      200,
      scrollable: homeScrollable.first,
    );
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonReaderScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
