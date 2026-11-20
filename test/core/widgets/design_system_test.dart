import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/core/widgets/app_button.dart';
import 'package:naru/core/widgets/app_card.dart';
import 'package:naru/core/widgets/app_empty_state.dart';
import 'package:naru/core/widgets/app_error_view.dart';
import 'package:naru/core/widgets/app_loading.dart';
import 'package:naru/core/widgets/app_progress_bar.dart';
import 'package:naru/core/widgets/app_text_field.dart';
import 'package:naru/core/widgets/section_title.dart';

void main() {
  testWidgets('loading button is disabled and shows progress', (tester) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Continuer',
            onPressed: () => wasPressed = true,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(wasPressed, isFalse);
  });

  testWidgets('all button variants render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final variant in AppButtonVariant.values)
                AppButton(
                  label: variant.name,
                  onPressed: () {},
                  variant: variant,
                  icon: variant == AppButtonVariant.icon ? Icons.add : null,
                ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('progress value is clamped to the supported range', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppProgressBar(value: 1.5))),
    );

    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
  });

  testWidgets('text field shows its validation error and disabled state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Adresse e-mail',
            errorText: 'Adresse invalide',
            enabled: false,
          ),
        ),
      ),
    );

    expect(find.text('Adresse invalide'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      isFalse,
    );
  });

  testWidgets('error view invokes its retry action', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            message: 'Réessayez plus tard.',
            onRetry: () => retryCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Réessayer'));
    expect(retryCount, 1);
  });

  testWidgets('generic design system widgets render together', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              AppCard(child: Text('Carte')),
              AppTextField(label: 'Recherche'),
              AppProgressBar(value: 0.4),
              AppEmptyState(title: 'Aucun résultat'),
              AppLoading(message: 'Chargement'),
              SectionTitle(title: 'Ma section'),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Carte'), findsOneWidget);
    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Ma section'), findsOneWidget);
  });
}
