import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/app.dart';
import 'package:naru/app/providers/auth_provider.dart';
import 'package:naru/app/router/app_router.dart';
import 'package:naru/app/router/app_routes.dart';
import 'package:naru/features/ai_assistant/models/assistant_mode.dart';
import 'package:naru/features/ai_assistant/providers/assistant_providers.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_conversation_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_documents_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_history_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_home_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_mode_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_modes_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_tools_screen.dart';
import 'package:naru/features/ai_assistant/presentation/screens/assistant_voice_screen.dart';
import 'package:naru/features/ai_assistant/models/assistant_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home opens Naru AI and suggested prompt starts a conversation', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.home);
    await tester.ensureVisible(find.text('Naru AI'));
    await tester.tap(find.text('Naru AI'));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantHomeScreen), findsOneWidget);

    final pageScroll = _screenScrollable(find.byType(AssistantHomeScreen))
        .first;
    await tester.scrollUntilVisible(
      find.text('Explique-moi les bases de Python.'),
      120,
      scrollable: pageScroll,
    );
    await tester.tap(find.text('Explique-moi les bases de Python.'));
    await tester.pumpAndSettle();
    final composer = find.descendant(
      of: find.byType(AssistantHomeScreen),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(composer.last).controller?.text,
      'Explique-moi les bases de Python.',
    );
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantConversationScreen), findsOneWidget);
    expect(
      find.text('Démonstration locale — aucune IA n’est connectée.'),
      findsOneWidget,
    );
    expect(
      container
          .read(assistantControllerProvider)
          .requireValue
          .usage
          .count(AssistantQuotaKind.messages),
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('conversation accepts follow-up messages', (tester) async {
    final container = await _pumpAtRoute(tester, AppRoutes.assistant);
    await container.read(assistantControllerProvider.future);
    final conversationId = await container
        .read(assistantControllerProvider.notifier)
        .createConversation(mode: AssistantMode.learn);
    container
        .read(appRouterProvider)
        .go(AppRoutes.assistantConversationPath(conversationId));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantConversationScreen), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'Explique les fractions.',
    );
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(assistantControllerProvider)
          .requireValue
          .conversations
          .single
          .messages,
      hasLength(2),
    );
    expect(find.text('Explique les fractions.'), findsOneWidget);
    expect(find.textContaining('Démonstration locale'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Donne un exemple.');
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pumpAndSettle();
    final conversation = container
        .read(assistantControllerProvider)
        .requireValue
        .conversations
        .single;
    expect(conversation.messages, hasLength(4));
    expect(conversation.messages[2].content, 'Donne un exemple.');
    expect(tester.takeException(), isNull);
  });

  testWidgets('message limit keeps the draft and offers a calm explanation', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.assistant);
    await container.read(assistantControllerProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);
    for (var index = 0; index < 20; index++) {
      await controller.recordQuotaUse(AssistantQuotaKind.messages);
    }

    final prompt = find.byType(TextField).last;
    await tester.enterText(prompt, 'Question après la limite');
    await tester.tap(find.byTooltip('Envoyer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Limite quotidienne atteinte'), findsOneWidget);
    expect(find.text('Continuer gratuitement'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Question après la limite',
    );
    await tester.tap(find.text('Continuer gratuitement'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      container.read(assistantControllerProvider).requireValue.conversations,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('history searches, renames, favorites, and deletes locally', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.assistantHistory);
    await container.read(assistantControllerProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);
    final conversationId = await controller.createConversation(
      mode: AssistantMode.learn,
    );
    await controller.renameConversation(
      conversationId,
      'Comprendre les fractions.',
    );
    await tester.pumpAndSettle();
    expect(find.byType(AssistantHistoryScreen), findsOneWidget);
    expect(find.text('Comprendre les fractions.'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Rechercher une conversation',
      ),
      'fractions',
    );
    await tester.pumpAndSettle();
    expect(find.text('Comprendre les fractions.'), findsOneWidget);

    await tester.tap(find.byTooltip('Ajouter aux favoris'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(assistantControllerProvider)
          .requireValue
          .conversations
          .single
          .isFavorite,
      isTrue,
    );

    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier le titre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Révision du chapitre');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text('Révision du chapitre'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Votre historique est vide'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('documents and voice are explicitly non-functional previews', (
    tester,
  ) async {
    final container = await _pumpAtRoute(tester, AppRoutes.assistantDocuments);
    expect(find.byType(AssistantDocumentsScreen), findsOneWidget);
    await tester.tap(find.text('Ajouter un exemple de document'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guide-de-revision.pdf'));
    await tester.pumpAndSettle();
    expect(find.textContaining('non analysé'), findsOneWidget);
    expect(
      container
          .read(assistantControllerProvider)
          .requireValue
          .documents
          .single
          .format,
      'PDF',
    );

    container.read(appRouterProvider).go(AppRoutes.assistantVoice);
    await tester.pumpAndSettle();
    expect(find.byType(AssistantVoiceScreen), findsOneWidget);
    await tester.tap(find.text('Lancer l’aperçu'));
    await tester.pump();
    expect(find.textContaining('non reconnu'), findsOneWidget);
    expect(find.text('Arrêter l’aperçu'), findsOneWidget);
    expect(
      container.read(assistantControllerProvider).requireValue.voiceHistory,
      hasLength(1),
    );
    container.read(appRouterProvider).go(AppRoutes.assistantHistory);
    await tester.pumpAndSettle();
    final exception = tester.takeException();
    expect(exception, isNull, reason: '$exception');
  });

  testWidgets('mode and tool catalogs open tailored forms', (tester) async {
    await _pumpAtRoute(tester, AppRoutes.assistantModes);
    await tester.scrollUntilVisible(
      find.text('Programmation'),
      120,
      scrollable: _screenScrollable(find.byType(AssistantModesScreen)).first,
    );
    final modesException = tester.takeException();
    expect(modesException, isNull, reason: 'modes: $modesException');
    await tester.tap(find.text('Programmation'));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantModeScreen), findsOneWidget);
    expect(find.text('Langage de programmation'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AssistantModeScreen)),
    );
    container.read(appRouterProvider).go(AppRoutes.assistantTools);
    await tester.pumpAndSettle();
    expect(find.byType(AssistantToolsScreen), findsOneWidget);
    expect(find.text('Générateur de résumés'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Assistant de programmation'),
      120,
      scrollable: _screenScrollable(find.byType(AssistantToolsScreen)).first,
    );
    expect(find.text('Assistant de programmation'), findsOneWidget);
    final exception = tester.takeException();
    expect(exception, isNull, reason: '$exception');
  });
}

Future<ProviderContainer> _pumpAtRoute(
  WidgetTester tester,
  String location,
) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(360, 760);
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
