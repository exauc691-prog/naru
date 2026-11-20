import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/auth_plan_screen.dart';
import '../../features/auth/screens/auth_profile_setup_screen.dart';
import '../../features/auth/screens/auth_verification_screen.dart';
import '../../features/ai_assistant/models/assistant_mode.dart';
import '../../features/ai_assistant/presentation/screens/assistant_conversation_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_documents_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_favorites_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_history_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_home_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_mode_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_modes_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_settings_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_tool_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_tools_screen.dart';
import '../../features/ai_assistant/presentation/screens/assistant_voice_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/learning/presentation/screens/course_catalog_screen.dart';
import '../../features/learning/presentation/screens/course_detail_screen.dart';
import '../../features/learning/presentation/screens/learning_path_detail_screen.dart';
import '../../features/learning/presentation/screens/learning_paths_screen.dart';
import '../../features/learning/presentation/screens/learning_screen.dart';
import '../../features/learning/presentation/screens/lesson_reader_screen.dart';
import '../../features/library/screens/library_catalog_screen.dart';
import '../../features/library/screens/library_collections_screen.dart';
import '../../features/library/screens/library_home_screen.dart';
import '../../features/library/screens/library_reader_screen.dart';
import '../../features/library/screens/library_resource_detail_screen.dart';
import '../../features/library/screens/library_downloads_screen.dart';
import '../../features/library/screens/my_library_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/learning/presentation/screens/goal_setup_screen.dart';
import '../../features/learning/presentation/screens/study_plan_screen.dart';
import '../../features/home/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/security_screen.dart';
import '../../features/personal/screens/personal_library_screen.dart';
import '../../features/personal/screens/notes_screen.dart';
import '../../features/personal/screens/bookmarks_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/info_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/progress/presentation/screens/achievements_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/search/screens/search_results_screen.dart';
import '../../features/assessment/screens/assessment_home_screen.dart';
import '../../features/assessment/screens/quiz_screen.dart';
import '../../features/assessment/screens/assessment_result_screen.dart';
import '../../features/assessment/screens/assessment_history_screen.dart';
import '../../features/assessment/screens/competency_screen.dart';
import '../../features/subscription/screens/subscription_settings_screen.dart';
import '../navigation/main_navigation.dart';
import '../navigation/temporary_pages.dart';
import '../providers/auth_provider.dart';
import '../router/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider).isAuthenticated;
      final path = state.uri.path;
      final isPublicEntry = {
        AppRoutes.welcome,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.authPlan,
        AppRoutes.authVerification,
        AppRoutes.authProfileSetup,
      }.contains(path);
      final isProtected = path.startsWith('/app/');

      if (!isAuthenticated && isProtected) {
        return Uri(
          path: AppRoutes.login,
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      if (isAuthenticated && isPublicEntry) {
        final destination = state.uri.queryParameters['from'];
        if (destination != null &&
            Uri.tryParse(destination)?.path.startsWith('/app/') == true) {
          return destination;
        }
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.authVerification,
        builder: (context, state) => AuthVerificationScreen(
          byPhone: state.uri.queryParameters['method'] == 'phone',
        ),
      ),
      GoRoute(
        path: AppRoutes.authPlan,
        builder: (context, state) => const AuthPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.authProfileSetup,
        builder: (context, state) => const AuthProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => SearchScreen(
          initialQuery: state.uri.queryParameters['query'] ?? '',
          initialType: state.uri.queryParameters['type'],
        ),
      ),
      GoRoute(
        path: AppRoutes.searchResults,
        builder: (context, state) => SearchResultsScreen(
          query: state.uri.queryParameters['query'] ?? '',
          initialType: state.uri.queryParameters['type'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'assistant',
                    builder: (context, state) => const AssistantHomeScreen(),
                    routes: [
                      GoRoute(
                        path: 'conversation/:conversationId',
                        builder: (context, state) =>
                            AssistantConversationScreen(
                              conversationId:
                                  state.pathParameters['conversationId'] ?? '',
                            ),
                      ),
                      GoRoute(
                        path: 'modes',
                        builder: (context, state) =>
                            const AssistantModesScreen(),
                      ),
                      GoRoute(
                        path: 'mode/:modeName',
                        builder: (context, state) => AssistantModeScreen(
                          mode: AssistantMode.values.byName(
                            state.pathParameters['modeName'] ?? '',
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'documents',
                        builder: (context, state) =>
                            const AssistantDocumentsScreen(),
                      ),
                      GoRoute(
                        path: 'voice',
                        builder: (context, state) =>
                            const AssistantVoiceScreen(),
                      ),
                      GoRoute(
                        path: 'history',
                        builder: (context, state) =>
                            const AssistantHistoryScreen(),
                      ),
                      GoRoute(
                        path: 'favorites',
                        builder: (context, state) =>
                            const AssistantFavoritesScreen(),
                      ),
                      GoRoute(
                        path: 'tools',
                        builder: (context, state) =>
                            const AssistantToolsScreen(),
                      ),
                      GoRoute(
                        path: 'tool/:toolId',
                        builder: (context, state) => AssistantToolScreen(
                          toolId: state.pathParameters['toolId'] ?? '',
                        ),
                      ),
                      GoRoute(
                        path: 'settings',
                        builder: (context, state) =>
                            const AssistantSettingsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'library',
                    builder: (context, state) => const LibraryHomeScreen(),
                    routes: [
                      GoRoute(
                        path: 'catalog',
                        builder: (context, state) => LibraryCatalogScreen(
                          initialQuery:
                              state.uri.queryParameters['query'] ?? '',
                          initialCategoryId:
                              state.uri.queryParameters['categoryId'],
                          initialType: state.uri.queryParameters['type'],
                          initialSort: state.uri.queryParameters['sort'],
                          collectionId:
                              state.uri.queryParameters['collectionId'],
                        ),
                      ),
                      GoRoute(
                        path: 'resource/:resourceId',
                        builder: (context, state) =>
                            LibraryResourceDetailScreen(
                              resourceId:
                                  state.pathParameters['resourceId'] ?? '',
                            ),
                      ),
                      GoRoute(
                        path: 'reader/:resourceId',
                        builder: (context, state) => LibraryReaderScreen(
                          resourceId: state.pathParameters['resourceId'] ?? '',
                        ),
                      ),
                      GoRoute(
                        path: 'my',
                        builder: (context, state) => const MyLibraryScreen(),
                      ),
                      GoRoute(
                        path: 'collections',
                        builder: (context, state) =>
                            const LibraryCollectionsScreen(),
                      ),
                      GoRoute(
                        path: 'collections/:collectionId',
                        builder: (context, state) => LibraryCollectionsScreen(
                          collectionId:
                              state.pathParameters['collectionId'] ?? '',
                        ),
                      ),
                      GoRoute(
                        path: 'downloads',
                        builder: (context, state) =>
                            const LibraryDownloadsScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learning,
                builder: (context, state) {
                  final query = state.uri.queryParameters['query']?.trim();
                  final domainId = state.uri.queryParameters['domainId'];
                  final categoryId = state.uri.queryParameters['categoryId'];
                  if ((query != null && query.isNotEmpty) ||
                      domainId != null ||
                      categoryId != null) {
                    return CourseCatalogScreen(
                      initialQuery: query ?? '',
                      initialDomainId: domainId,
                      initialCategoryId: categoryId,
                    );
                  }
                  return const LearningScreen();
                },
                routes: [
                  GoRoute(
                    path: 'courses',
                    builder: (context, state) => CourseCatalogScreen(
                      initialQuery:
                          state.uri.queryParameters['query']?.trim() ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'paths',
                    builder: (context, state) => const LearningPathsScreen(),
                  ),
                  GoRoute(
                    path: 'goal/setup',
                    builder: (context, state) => const GoalSetupScreen(),
                  ),
                  GoRoute(
                    path: 'plan',
                    builder: (context, state) => const StudyPlanScreen(),
                  ),
                  GoRoute(
                    path: 'course/:courseId',
                    builder: (context, state) => CourseDetailScreen(
                      courseId: state.pathParameters['courseId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'path/:pathId',
                    builder: (context, state) => LearningPathDetailScreen(
                      pathId: state.pathParameters['pathId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'module/:moduleId',
                    builder: (context, state) => TemporaryPage(
                      title: 'Détail du module',
                      description:
                          'Module : ${state.pathParameters['moduleId'] ?? ''}.',
                    ),
                  ),
                  GoRoute(
                    path: 'lesson/:lessonId',
                    builder: (context, state) => LessonReaderScreen(
                      lessonId: state.pathParameters['lessonId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practice,
                builder: (context, state) => const AssessmentHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) =>
                        const AssessmentHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'competencies',
                    builder: (context, state) => const CompetencyScreen(),
                  ),
                  GoRoute(
                    path: 'result',
                    builder: (context, state) => AssessmentResultScreen(
                      attemptId:
                          state.uri.queryParameters['attemptId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'exercise/:exerciseId',
                    builder: (context, state) => QuizScreen(
                      assessmentId:
                          state.pathParameters['exerciseId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'achievements',
                    builder: (context, state) =>
                        const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'contents',
                    builder: (context, state) =>
                        const PersonalLibraryScreen(),
                    routes: [
                      GoRoute(
                        path: 'notes',
                        builder: (context, state) =>
                            const PersonalNotesScreen(),
                      ),
                      GoRoute(
                        path: 'bookmarks',
                        builder: (context, state) =>
                            const PersonalBookmarksScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) =>
                        const SubscriptionSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'preferences',
                    builder: (context, state) =>
                        const AppSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) =>
                        const AppSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    builder: (context, state) =>
                        const AchievementsScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const InfoScreen(
                      title: 'Aide',
                      message:
                          'Pour obtenir de l’aide, consultez les tutoriels Naru '
                          'ou contactez l’équipe lorsque le support sera connecté.',
                    ),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const InfoScreen(
                      title: 'Confidentialité',
                      message:
                          'Vos préférences et contenus locaux restent sur cet '
                          'appareil dans cette démonstration. Les règles de '
                          'confidentialité pourront être synchronisées avec le backend.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
  );

  ref.listen(authStateProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

