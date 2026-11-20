import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/app_theme.dart';
import 'package:naru/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('system mode follows device brightness and user changes apply', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(() {
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const NaruApp(home: Scaffold(body: Text('Naru'))),
      ),
    );
    await tester.pumpAndSettle();

    var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.useMaterial3, isTrue);
    expect(app.theme?.brightness, Brightness.light);
    expect(app.darkTheme?.brightness, Brightness.dark);
    expect(
      Theme.of(tester.element(find.text('Naru'))).brightness,
      Brightness.light,
    );

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Naru'))).brightness,
      Brightness.dark,
    );

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('Naru'))).brightness,
      Brightness.light,
    );

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.system);
    await tester.pumpAndSettle();
    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(
      Theme.of(tester.element(find.text('Naru'))).brightness,
      Brightness.dark,
    );

    expect(app.theme?.colorScheme.brightness, Brightness.light);
    expect(app.darkTheme?.colorScheme.brightness, Brightness.dark);
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
    expect(AppTheme.darkTheme.useMaterial3, isTrue);
  });
}
