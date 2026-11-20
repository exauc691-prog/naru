import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'onboarding pages support next, previous, swipe, and completion',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const NaruApp()),
      );
      container.read(appRouterProvider).go(AppRoutes.onboarding);
      await tester.pumpAndSettle();

      expect(find.text('Apprenez ce qui vous passionne'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
      expect(
        find.text('Chaque étape vous rapproche de vos objectifs'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Précédent'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 3'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);

      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('Un assistant intelligent à vos côtés'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        Theme.of(
          tester.element(find.text('Un assistant intelligent à vos côtés')),
        ).brightness,
        Brightness.dark,
      );

      await tester.tap(find.text('Commencer maintenant'));
      await tester.pumpAndSettle();
      expect(find.text('Créer votre compte'), findsOneWidget);

      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      expect(find.text('Un assistant intelligent à vos côtés'), findsOneWidget);
    },
  );

  testWidgets('skip goes directly to the registration route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const NaruApp()),
    );
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go(AppRoutes.onboarding);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Créer votre compte'), findsOneWidget);
    expect(container.read(authStateProvider).isAuthenticated, isFalse);
  });
}
