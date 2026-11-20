import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/ai_assistant/widgets/assistant_response_renderer.dart';

void main() {
  testWidgets('renders headings, lists, formulas, and selectable code', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AssistantResponseRenderer(
              content: r'''
# Étapes
- Première idée
$$x + y$$
```dart
int somme(int x, int y) => x + y;
```''',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Étapes'), findsOneWidget);
    expect(find.text('Première idée'), findsOneWidget);
    expect(find.text('x + y'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data?.contains('int somme') == true,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
