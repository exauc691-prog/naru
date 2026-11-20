import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:naru/main.dart';

void main() {
  testWidgets('Naru opens on welcome and can show the onboarding route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('J’ai déjà un compte'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Commencer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Apprenez ce qui vous passionne'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('welcome account button opens the login route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('J’ai déjà un compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('J’ai déjà un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Bon retour parmi nous'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
