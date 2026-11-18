import '../models/enums/difficulty_level.dart';
import '../models/user_model.dart';
import 'mock_dates.dart';

final mockUser = UserModel(
  id: 'user-samira-01',
  fullName: 'Samira Benali',
  email: 'samira.benali@example.test',
  avatarUrl: null,
  selectedDomains: [
    'programmation',
    'developpement-mobile',
    'intelligence-artificielle',
  ],
  currentLevel: DifficultyLevel.beginner,
  learningGoals: [
    'Créer une première application Flutter.',
    'Pratiquer un peu chaque jour.',
    'Comprendre les bases de l’intelligence artificielle.',
  ],
  dailyLearningMinutes: 20,
  joinedAt: mockDate(daysAgo: 42, hour: 8, minute: 30),
  isOnboardingCompleted: true,
);
