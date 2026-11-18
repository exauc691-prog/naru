import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/personal_learning_models.dart';

class PersonalLearningStore {
  const PersonalLearningStore();

  static const _goalKey = 'naru.learning.goals.v1';
  static const _sessionKey = 'naru.learning.study_sessions.v1';

  Future<List<PersonalLearningGoal>> getGoals() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_goalKey) ?? const [];
    return [
      for (final value in values)
        PersonalLearningGoal.fromJson(
          Map<String, dynamic>.from(jsonDecode(value) as Map),
        ),
    ];
  }

  Future<void> saveGoal(PersonalLearningGoal goal) async {
    final preferences = await SharedPreferences.getInstance();
    final goals = await getGoals();
    final next = [
      goal,
      ...goals.where((item) => item.id != goal.id),
    ];
    await preferences.setStringList(
      _goalKey,
      next.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> deleteGoal(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final goals = await getGoals();
    await preferences.setStringList(
      _goalKey,
      goals
          .where((item) => item.id != id)
          .map((item) => jsonEncode(item.toJson()))
          .toList(),
    );
  }

  Future<List<PersonalStudySession>> getSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_sessionKey);
    if (values != null) {
      return [
        for (final value in values)
          PersonalStudySession.fromJson(
            Map<String, dynamic>.from(jsonDecode(value) as Map),
          ),
      ];
    }
    return _defaultSessions();
  }

  Future<void> toggleSession(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final sessions = await getSessions();
    await preferences.setStringList(
      _sessionKey,
      sessions
          .map(
            (session) => jsonEncode(
              PersonalStudySession(
                id: session.id,
                day: session.day,
                title: session.title,
                durationMinutes: session.durationMinutes,
                isCompleted:
                    session.id == id ? !session.isCompleted : session.isCompleted,
              ).toJson(),
            ),
          )
          .toList(),
    );
  }

  List<PersonalStudySession> _defaultSessions() => const [
    PersonalStudySession(
      id: 'monday',
      day: 'Lundi',
      title: 'Fondamentaux et notions clés',
      durationMinutes: 30,
      isCompleted: true,
    ),
    PersonalStudySession(
      id: 'tuesday',
      day: 'Mardi',
      title: 'Leçon principale',
      durationMinutes: 30,
      isCompleted: false,
    ),
    PersonalStudySession(
      id: 'wednesday',
      day: 'Mercredi',
      title: 'Exercice pratique',
      durationMinutes: 30,
      isCompleted: false,
    ),
    PersonalStudySession(
      id: 'thursday',
      day: 'Jeudi',
      title: 'Application guidée',
      durationMinutes: 30,
      isCompleted: false,
    ),
    PersonalStudySession(
      id: 'friday',
      day: 'Vendredi',
      title: 'Révision',
      durationMinutes: 30,
      isCompleted: false,
    ),
  ];
}
