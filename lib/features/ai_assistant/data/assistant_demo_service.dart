import '../models/assistant_mode.dart';

class AssistantDemoService {
  const AssistantDemoService();

  Future<String> createResponse(AssistantMode mode, String prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final subject = prompt.trim().replaceAll(RegExp(r'\s+'), ' ');
    final shortSubject = subject.length > 72
        ? '${subject.substring(0, 69)}…'
        : subject;

    final body = switch (mode) {
      AssistantMode.learn =>
        'Pour aborder « $shortSubject », commencez par identifier les idées '
            'essentielles, puis reliez-les à un exemple concret.\n\n'
            '**Une méthode en trois temps**\n'
            '- Reformulez la notion avec vos mots.\n'
            '- Observez un exemple simple.\n'
            '- Vérifiez votre compréhension avec une question.',
      AssistantMode.homework =>
        'Pour avancer sur « $shortSubject », décomposez d’abord l’exercice '
            'en données connues, objectif et méthode.\n\n'
            '**Étapes de réflexion**\n'
            '1. Repérez ce que l’énoncé demande.\n'
            '2. Choisissez une règle ou une formule adaptée.\n'
            '3. Vérifiez le résultat et expliquez votre raisonnement.\n\n'
            'Cette réponse d’exemple ne résout pas réellement un exercice.',
      AssistantMode.writing =>
        'Pour structurer « $shortSubject », essayez ce plan de départ :\n\n'
            '1. **Introduction** — contexte et objectif.\n'
            '2. **Développement** — une idée par partie, avec exemples.\n'
            '3. **Conclusion** — synthèse et ouverture.\n\n'
            'Exemple local à adapter : « Présentons d’abord le sujet, '
            'examinons ensuite ses enjeux, puis retenons les idées clés. »',
      AssistantMode.documents =>
        'Aucun document n’a été lu ou analysé. Cette réponse locale illustre '
            'seulement une structure possible : résumé, idées principales, '
            'questions de compréhension et fiche de révision.',
      AssistantMode.programming =>
        'Exemple pédagogique local autour de « $shortSubject ». Ce code '
            'n’a pas été exécuté ni vérifié :\n\n'
            '```dart\n'
            'String saluer(String nom) => \'Bonjour, \$nom\';\n'
            '```\n\n'
            'Repérez le type du paramètre, la valeur retournée et la fonction '
            'fléchée.',
      AssistantMode.translation =>
        'Aucune traduction automatique n’est connectée. Pour préparer '
            '« $shortSubject », indiquez les langues source et cible puis '
            'comparez le sens, le registre et les expressions idiomatiques.',
      AssistantMode.organization =>
        'Voici un canevas local pour organiser « $shortSubject » :\n\n'
            '- **Objectif** : définir le résultat attendu.\n'
            '- **Étapes** : découper le travail en actions courtes.\n'
            '- **Échéance** : choisir un rythme réaliste.\n'
            '- **Bilan** : revoir les priorités régulièrement.',
    };

    return 'Démonstration locale — aucune IA n’est connectée.\n\n$body';
  }
}
