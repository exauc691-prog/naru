import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/core/providers/theme_provider.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';
import 'package:naru/features/subscription/providers/subscription_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('registration saves the selected subscription plan', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.register);

    await _tap(tester, 'Choisir Premium');
    await _enterField(tester, 0, 'Samira Naru');
    await _enterField(tester, 1, 'samira@naru.app');
    await _enterField(tester, 2, 'naru-password');
    await _enterField(tester, 3, 'naru-password');
    await _tap(tester, 'J’accepte les conditions d’utilisation.');
    await _submitAndWait(tester, 'Créer mon compte');

    expect(
      await container.read(subscriptionPlanProvider.future),
      SubscriptionPlan.premium,
    );
    expect(container.read(authStateProvider).isAuthenticated, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'registration validates every field and simulates account creation',
    (tester) async {
      final container = await _pumpAtRoute(tester, AppRoutes.register);

      await _tap(tester, 'Créer mon compte');
      expect(find.text('Saisissez votre nom complet.'), findsOneWidget);
      expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
      expect(find.text('Saisissez un mot de passe.'), findsOneWidget);
      expect(find.text('Confirmez votre mot de passe.'), findsOneWidget);
      expect(
        find.text('Veuillez accepter les conditions d’utilisation.'),
        findsOneWidget,
      );

      await _enterField(tester, 0, 'Samira Naru');
      await _enterField(tester, 1, 'samira@naru.app');
      await _enterField(tester, 2, 'naru-password');
      await _enterField(tester, 3, 'different-password');
      await _tap(tester, 'J’accepte les conditions d’utilisation.');
      await _tap(tester, 'Créer mon compte');
      expect(
        find.text('Les mots de passe ne correspondent pas.'),
        findsOneWidget,
      );

      await _enterField(tester, 3, 'naru-password');
      await _submitAndWait(tester, 'Créer mon compte');
      expect(find.text('Bonjour, Samira'), findsOneWidget);
      expect(container.read(authStateProvider).isAuthenticated, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'login validates fields and simulates a protected-session login',
    (tester) async {
      final container = await _pumpAtRoute(tester, AppRoutes.login);

      expect(tester.takeException(), isNull);
      await _tap(tester, 'Se connecter');
      expect(find.text('Saisissez votre adresse e-mail.'), findsOneWidget);
      expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);

      await _enterField(tester, 0, 'samira@naru.app');
      await _enterField(tester, 1, 'demo-password');
      await _tap(tester, 'Se souvenir de moi');
      expect(
        tester
            .widget<CheckboxListTile>(
              find.ancestor(
                of: find.text('Se souvenir de moi'),
                matching: find.byType(CheckboxListTile),
              ),
            )
            .value,
        isTrue,
      );
      await _submitAndWait(tester, 'Se connecter');

      expect(find.text('Bonjour, Samira'), findsOneWidget);
      expect(container.read(authStateProvider).isAuthenticated, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('password visibility can be toggled', (tester) async {
    await _pumpAtRoute(tester, AppRoutes.login);
    final passwordField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(passwordField);
    final textField = find.byType(TextField).at(1);
    expect(tester.widget<TextField>(textField).obscureText, isTrue);

    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(tester.widget<TextField>(textField).obscureText, isFalse);

    await tester.tap(find.byTooltip('Masquer le mot de passe'));
    await tester.pump();
    expect(tester.widget<TextField>(textField).obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'password recovery validates locally and confirms only a simulation',
    (tester) async {
      final container = await _pumpAtRoute(tester, AppRoutes.forgotPassword);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Mot de passe oublié ?').first))
            .brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);

      await _enterField(tester, 0, 'invalid');
      await _tap(tester, 'Envoyer les instructions');
      expect(find.text('Saisissez une adresse e-mail valide.'), findsOneWidget);

      await _enterField(tester, 0, 'samira@naru.app');
      await _submitAndWait(tester, 'Envoyer les instructions');
      expect(find.text('Demande simulée'), findsOneWidget);
      expect(
        find.textContaining('Aucun e-mail n’a été envoyé.'),
        findsOneWidget,
      );
      expect(container.read(authStateProvider).isAuthenticated, isFalse);
      expect(tester.takeException(), isNull);

      await _tap(tester, 'Retour à la connexion');
      expect(find.text('Bon retour parmi nous'), findsOneWidget);
    },
  );

  testWidgets('login and registration links navigate between auth screens', (
    tester,
  ) async {
    await _pumpAtRoute(tester, AppRoutes.register);
    await _tap(tester, 'Se connecter');
    expect(find.text('Bon retour parmi nous'), findsOneWidget);

    await _tap(tester, 'Mot de passe oublié ?');
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    await _tap(tester, 'Retour à la connexion');
    expect(find.text('Bon retour parmi nous'), findsOneWidget);

    await _tap(tester, 'Créer un compte');
    expect(find.text('Créer votre compte'), findsOneWidget);
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
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NaruApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

Future<void> _enterField(WidgetTester tester, int index, String value) async {
  final field = find.byType(TextFormField).at(index);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _submitAndWait(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}
