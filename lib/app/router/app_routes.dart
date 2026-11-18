abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const authPlan = '/auth/plan';
  static const authVerification = '/auth/verification';
  static const authProfileSetup = '/auth/profile/setup';
  static const authWelcome = '/auth/welcome';
  static const profileSecurity = '/app/profile/security';
  static const search = '/app/search';
  static const searchResults = '/app/search/results';

  static const home = '/app/home';
  static const library = '/app/home/library';
  static const libraryCatalog = '/app/home/library/catalog';
  static const libraryResource = '/app/home/library/resource/:resourceId';
  static const libraryReader = '/app/home/library/reader/:resourceId';
  static const myLibrary = '/app/home/library/my';
  static const libraryCollections = '/app/home/library/collections';
  static const libraryCollection =
      '/app/home/library/collections/:collectionId';
  static const libraryDownloads = '/app/home/library/downloads';
  static const learning = '/app/learning';
  static const courseCatalog = '/app/learning/courses';
  static const learningPaths = '/app/learning/paths';
  static const goalSetup = '/app/learning/goal/setup';
  static const studyPlan = '/app/learning/plan';
  static const practice = '/app/practice';
  static const progress = '/app/progress';
  static const profile = '/app/profile';

  static const courseDetails = '/app/learning/course/:courseId';
  static const learningPathDetails = '/app/learning/path/:pathId';
  static const moduleDetails = '/app/learning/module/:moduleId';
  static const lessonDetails = '/app/learning/lesson/:lessonId';
  static const exerciseDetails = '/app/practice/exercise/:exerciseId';
  static const exerciseResults = '/app/practice/exercise/:exerciseId/results';
  static const assessmentHistory = '/app/practice/history';
  static const competencies = '/app/practice/competencies';
  static const assessmentResult = '/app/practice/result';

  static const assistant = '/app/home/assistant';
  static const assistantModes = '/app/home/assistant/modes';
  static const assistantMode = '/app/home/assistant/mode/:modeName';
  static const assistantConversation =
      '/app/home/assistant/conversation/:conversationId';
  static const assistantDocuments = '/app/home/assistant/documents';
  static const assistantVoice = '/app/home/assistant/voice';
  static const assistantHistory = '/app/home/assistant/history';
  static const assistantFavorites = '/app/home/assistant/favorites';
  static const assistantTools = '/app/home/assistant/tools';
  static const assistantTool = '/app/home/assistant/tool/:toolId';
  static const assistantSettings = '/app/home/assistant/settings';
  static const notifications = '/app/home/notifications';
  static const settings = '/app/profile/settings';
  static const editProfile = '/app/profile/edit';
  static const achievements = '/app/profile/achievements';
  static const personalContents = '/app/profile/contents';
  static const personalNotes = '/app/profile/contents/notes';
  static const personalBookmarks = '/app/profile/contents/bookmarks';
  static const appearanceSettings = '/app/profile/appearance';
  static const preferencesSettings = '/app/profile/preferences';
  static const help = '/app/profile/help';
  static const privacy = '/app/profile/privacy';

  static String learningSearchPath(String query) =>
      Uri(path: learning, queryParameters: {'query': query.trim()}).toString();

  static String assistantConversationPath(String conversationId) =>
      '/app/home/assistant/conversation/${Uri.encodeComponent(conversationId)}';

  static String assistantModePath(String modeName) =>
      '/app/home/assistant/mode/${Uri.encodeComponent(modeName)}';

  static String assistantToolPath(String toolId) =>
      '/app/home/assistant/tool/${Uri.encodeComponent(toolId)}';

  static String libraryCatalogPath({
    String? query,
    String? categoryId,
    String? type,
    String? sort,
    String? collectionId,
  }) => Uri(
    path: libraryCatalog,
    queryParameters: {
      'query': ?_nonEmpty(query),
      'categoryId': ?categoryId,
      'type': ?type,
      'sort': ?sort,
      'collectionId': ?collectionId,
    },
  ).toString();

  static String libraryResourcePath(String resourceId) =>
      '/app/home/library/resource/${Uri.encodeComponent(resourceId)}';

  static String libraryReaderPath(String resourceId) =>
      '/app/home/library/reader/${Uri.encodeComponent(resourceId)}';

  static String libraryCollectionPath(String collectionId) =>
      '/app/home/library/collections/${Uri.encodeComponent(collectionId)}';

  static String learningDomainPath(
    String domainId, {
    required String domainName,
  }) => Uri(
    path: learning,
    queryParameters: {'domainId': domainId, 'domainName': domainName},
  ).toString();

  static String learningCategoryPath(String categoryId) => Uri(
    path: learning,
    queryParameters: {'categoryId': categoryId},
  ).toString();

  static String courseCatalogPath({String? query}) => Uri(
    path: courseCatalog,
    queryParameters: query == null || query.trim().isEmpty
        ? null
        : {'query': query.trim()},
  ).toString();

  static String courseDetailsPath(String courseId) =>
      '/app/learning/course/${Uri.encodeComponent(courseId)}';

  static String learningPathDetailsPath(String pathId) =>
      '/app/learning/path/${Uri.encodeComponent(pathId)}';

  static String moduleDetailsPath(String moduleId) =>
      '/app/learning/module/${Uri.encodeComponent(moduleId)}';

  static String lessonDetailsPath(String lessonId) =>
      '/app/learning/lesson/${Uri.encodeComponent(lessonId)}';

  static String exerciseDetailsPath(String exerciseId) =>
      '/app/practice/exercise/${Uri.encodeComponent(exerciseId)}';

  static String exerciseResultsPath(String exerciseId) =>
      '${exerciseDetailsPath(exerciseId)}/results';

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
