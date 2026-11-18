enum AssistantMode {
  learn,
  homework,
  writing,
  documents,
  programming,
  translation,
  organization,
}

extension AssistantModeDetails on AssistantMode {
  String get label => switch (this) {
    AssistantMode.learn => 'Apprendre',
    AssistantMode.homework => 'Aide aux devoirs',
    AssistantMode.writing => 'Rédaction',
    AssistantMode.documents => 'Documents',
    AssistantMode.programming => 'Programmation',
    AssistantMode.translation => 'Traduction',
    AssistantMode.organization => 'Organisation',
  };

  String get description => switch (this) {
    AssistantMode.learn =>
      'Progressez avec des explications et des exemples adaptés.',
    AssistantMode.homework =>
      'Comprenez la méthode et avancez étape par étape.',
    AssistantMode.writing => 'Organisez vos idées et améliorez vos textes.',
    AssistantMode.documents =>
      'Préparez vos documents pour une future analyse.',
    AssistantMode.programming => 'Explorez le code et apprenez à programmer.',
    AssistantMode.translation =>
      'Préparez une traduction et comparez les langues.',
    AssistantMode.organization => 'Transformez vos idées en plans concrets.',
  };

  String get category => switch (this) {
    AssistantMode.learn || AssistantMode.homework => 'Études',
    AssistantMode.programming => 'Programmation',
    AssistantMode.writing => 'Rédaction',
    AssistantMode.documents => 'Documents',
    _ => 'Autres',
  };
}
