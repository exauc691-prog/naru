enum OnboardingIllustration {
  learningDomains,
  learningProgress,
  learningAssistant,
}

class OnboardingContent {
  const OnboardingContent({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;
  final OnboardingIllustration illustration;
}

const onboardingContent = [
  OnboardingContent(
    title: 'Apprenez ce qui vous passionne',
    description:
        'Explorez différents domaines, découvrez des cours structurés et '
        'développez de nouvelles compétences à votre rythme.',
    illustration: OnboardingIllustration.learningDomains,
  ),
  OnboardingContent(
    title: 'Chaque étape vous rapproche de vos objectifs',
    description:
        'Suivez votre progression, réalisez des exercices pratiques et '
        'développez vos compétences grâce à un parcours adapté à votre évolution.',
    illustration: OnboardingIllustration.learningProgress,
  ),
  OnboardingContent(
    title: 'Un assistant intelligent à vos côtés',
    description:
        'Posez vos questions, demandez des explications et bénéficiez d’un '
        'accompagnement intelligent pendant votre apprentissage.',
    illustration: OnboardingIllustration.learningAssistant,
  ),
];
