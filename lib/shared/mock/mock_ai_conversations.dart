import '../models/ai_conversation_model.dart';
import '../models/ai_message_model.dart';
import '../models/enums/ai_message_sender.dart';
import '../models/enums/ai_message_type.dart';
import 'mock_dates.dart';

final mockAIConversations = List<AIConversationModel>.unmodifiable([
  _conversation(
    id: 'conversation-dart-variables',
    title: 'Comprendre les variables en Dart',
    messages: [
      _userMessage(
        'conversation-dart-variables',
        'message-variables-user-1',
        'Quelle est la différence entre var et final ?',
        daysAgo: 8,
        hour: 10,
      ),
      _assistantMessage(
        'conversation-dart-variables',
        'message-variables-assistant-1',
        'var te permet de réassigner la variable. final fixe sa référence après '
            'la première valeur. Si tu ne prévois pas de réassignation, final '
            'exprime mieux ton intention.',
        daysAgo: 8,
        hour: 10,
        minute: 1,
      ),
      _userMessage(
        'conversation-dart-variables',
        'message-variables-user-2',
        'Et const, quand est-ce que je le choisis ?',
        daysAgo: 8,
        hour: 10,
        minute: 2,
      ),
      _assistantMessage(
        'conversation-dart-variables',
        'message-variables-assistant-2',
        'const convient à une valeur connue comme constante à la compilation. '
            'Pour une valeur calculée ou reçue pendant l’exécution, final est '
            'souvent le bon choix.',
        daysAgo: 8,
        hour: 10,
        minute: 3,
      ),
    ],
  ),
  _conversation(
    id: 'conversation-list-map',
    title: 'Différence entre List et Map',
    messages: [
      _userMessage(
        'conversation-list-map',
        'message-collections-user-1',
        'Quand utiliser une List plutôt qu’une Map ?',
        daysAgo: 6,
        hour: 14,
      ),
      _assistantMessage(
        'conversation-list-map',
        'message-collections-assistant-1',
        'Utilise une List quand l’ordre et la position des éléments comptent. '
            'Choisis une Map quand tu veux retrouver une valeur par une clé, '
            'comme un identifiant ou un nom.',
        daysAgo: 6,
        hour: 14,
        minute: 1,
      ),
      _userMessage(
        'conversation-list-map',
        'message-collections-user-2',
        'La lecture d’une clé de Map peut-elle échouer ?',
        daysAgo: 6,
        hour: 14,
        minute: 2,
      ),
      _assistantMessage(
        'conversation-list-map',
        'message-collections-assistant-2',
        'Oui. Si la clé n’existe pas, la lecture renvoie null. Tu peux vérifier '
            'containsKey ou prévoir une valeur de remplacement.',
        daysAgo: 6,
        hour: 14,
        minute: 3,
      ),
    ],
  ),
  _conversation(
    id: 'conversation-dart-functions',
    title: 'Comprendre les fonctions',
    messages: [
      _userMessage(
        'conversation-dart-functions',
        'message-functions-user-1',
        'À quoi sert le type de retour d’une fonction ?',
        daysAgo: 3,
        hour: 16,
      ),
      _assistantMessage(
        'conversation-dart-functions',
        'message-functions-assistant-1',
        'Il annonce le type de la valeur renvoyée. Une fonction qui renvoie un '
            'nombre entier peut commencer par int et terminer par return.',
        daysAgo: 3,
        hour: 16,
        minute: 1,
      ),
      _assistantMessage(
        'conversation-dart-functions',
        'message-functions-assistant-2',
        'Par exemple :\nint doubleValue(int value) => value * 2;',
        daysAgo: 3,
        hour: 16,
        minute: 2,
        messageType: AIMessageType.code,
      ),
    ],
  ),
  _conversation(
    id: 'conversation-learning-plan',
    title: 'Préparer un petit programme d’apprentissage',
    messages: [
      _userMessage(
        'conversation-learning-plan',
        'message-plan-user-1',
        'Je peux étudier environ 20 minutes par jour. Comment rester régulière ?',
        daysAgo: 1,
        hour: 18,
      ),
      _assistantMessage(
        'conversation-learning-plan',
        'message-plan-assistant-1',
        'Choisis une seule petite leçon à la fois, puis garde quelques minutes '
            'pour noter ce que tu as compris. Prévois aussi des jours de repos : '
            'la régularité doit rester soutenable.',
        daysAgo: 1,
        hour: 18,
        minute: 1,
      ),
      _userMessage(
        'conversation-learning-plan',
        'message-plan-user-2',
        'Et si je manque une journée ?',
        daysAgo: 1,
        hour: 18,
        minute: 2,
      ),
      _assistantMessage(
        'conversation-learning-plan',
        'message-plan-assistant-2',
        'Reprends simplement avec une courte session quand tu es disponible. '
            'Un rythme réaliste compte davantage qu’une série parfaite.',
        daysAgo: 1,
        hour: 18,
        minute: 3,
      ),
    ],
  ),
]);

AIConversationModel _conversation({
  required String id,
  required String title,
  required List<AIMessageModel> messages,
}) => AIConversationModel(
  id: id,
  title: title,
  messages: messages,
  createdAt: messages.first.createdAt,
  updatedAt: messages.last.createdAt,
);

AIMessageModel _userMessage(
  String conversationId,
  String id,
  String content, {
  required int daysAgo,
  required int hour,
  int minute = 0,
}) => AIMessageModel(
  id: id,
  conversationId: conversationId,
  content: content,
  sender: AIMessageSender.user,
  createdAt: mockDate(daysAgo: daysAgo, hour: hour, minute: minute),
  messageType: AIMessageType.text,
);

AIMessageModel _assistantMessage(
  String conversationId,
  String id,
  String content, {
  required int daysAgo,
  required int hour,
  int minute = 0,
  AIMessageType messageType = AIMessageType.text,
}) => AIMessageModel(
  id: id,
  conversationId: conversationId,
  content: content,
  sender: AIMessageSender.assistant,
  createdAt: mockDate(daysAgo: daysAgo, hour: hour, minute: minute),
  messageType: messageType,
);
