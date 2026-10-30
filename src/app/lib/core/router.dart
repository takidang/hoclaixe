import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/exam/presentation/exam_list_screen.dart';
import '../features/exam/presentation/exam_result_screen.dart';
import '../features/exam/presentation/exam_review_screen.dart';
import '../features/exam/presentation/exam_screen.dart';
import '../features/exam/presentation/exam_start_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/license_class_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/signs/presentation/sign_catalog_screen.dart';
import '../features/signs/presentation/sign_detail_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/study/domain/study_topic.dart';
import '../features/study/presentation/question_search_screen.dart';
import '../features/study/presentation/saved_screen.dart';
import '../features/study/presentation/study_screen.dart';
import '../features/study/presentation/topic_list_screen.dart';
import '../shared/widgets/app_shell.dart';
import 'settings/app_settings.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const disclaimer = '/disclaimer';
  static const licenseClass = '/license';
  static const home = '/';
  static const about = '/about';
  static const study = '/study';
  static String studyTopic(String topicId) => '/study/$topicId';
  static const exam = '/exam';
  static String examStart({int? fixedSet}) =>
      fixedSet == null ? '/exam/start' : '/exam/start?set=$fixedSet';
  static String examSession(int id) => '/exam/session/$id';
  static String examResult(int id) => '/exam/result/$id';
  static String examReview(int id) => '/exam/review/$id';
  static const wrong = '/wrong';
  static const critical = '/critical';
  static const saved = '/saved';
  static const search = '/search';
  static const signs = '/signs';
  static const stats = '/stats';
  static String sign(String code) => '/signs/${Uri.encodeComponent(code)}';
}

/// Onboarding gate (FR-A01, FR-A03): disclaimer first, then licence class, then the app.
/// Pure function so it is unit-tested without widgets.
String? onboardingRedirect(AsyncValue<AppSettings> settings, String location) {
  final s = settings.value;
  final String target;
  if (s == null) {
    target = Routes.splash; // loading or error
  } else if (!s.disclaimerAccepted) {
    target = Routes.disclaimer;
  } else if (s.licenseClass == null) {
    target = Routes.licenseClass;
  } else {
    final onboarding =
        location == Routes.splash || location == Routes.disclaimer;
    return onboarding ? Routes.home : null;
  }
  return location == target ? null : target;
}

/// All routes (ADR-005). Re-evaluates the redirect whenever settings change.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(settingsProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);
  final root = GlobalKey<NavigatorState>();

  /// A screen that opens over the tab bar, full screen (design v2).
  GoRoute page(
    String path,
    Widget Function(GoRouterState s) build, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: root,
    builder: (context, state) => build(state),
    routes: routes,
  );

  return GoRouter(
    navigatorKey: root,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        onboardingRedirect(ref.read(settingsProvider), state.uri.path),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.disclaimer,
        builder: (context, state) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: Routes.licenseClass,
        builder: (context, state) => const LicenseClassScreen(),
      ),
      // Tabs: Tổng quan · Học · Câu đã lưu · Thống kê, each keeping its own state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              // Features are children of home, so going straight to one (e.g. "Thi đề khác") keeps home below it.
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  page('about', (_) => const AboutScreen()),
                  page('search', (_) => const QuestionSearchScreen()),
                  // Home cards open the study screen directly (ST-07, FR-A41, FR-A42).
                  page(
                    'wrong',
                    (_) => StudyScreen(
                      topicId: StudyTopic.wrongOf(StudyTopic.allId),
                    ),
                  ),
                  page(
                    'critical',
                    (_) => const StudyScreen(topicId: StudyTopic.criticalId),
                  ),
                  // Practice tests (ST-08 … ST-11)
                  page(
                    'exam',
                    (_) => const ExamListScreen(),
                    routes: [
                      page(
                        'start',
                        (s) => ExamStartScreen(
                          fixedSet: int.tryParse(
                            s.uri.queryParameters['set'] ?? '',
                          ),
                        ),
                      ),
                      page(
                        'session/:id',
                        (s) => ExamScreen(
                          sessionId: int.parse(s.pathParameters['id']!),
                        ),
                      ),
                      page(
                        'result/:id',
                        (s) => ExamResultScreen(
                          sessionId: int.parse(s.pathParameters['id']!),
                        ),
                      ),
                      page(
                        'review/:id',
                        (s) => ExamReviewScreen(
                          sessionId: int.parse(s.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                  // Traffic sign catalog (ST-12, ST-16)
                  page(
                    'signs',
                    (_) => const SignCatalogScreen(),
                    routes: [
                      page(
                        ':code',
                        (s) =>
                            SignDetailScreen(code: s.pathParameters['code']!),
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
                path: Routes.study,
                builder: (context, state) => const TopicListScreen(),
                routes: [
                  page(
                    ':topicId',
                    (s) => StudyScreen(topicId: s.pathParameters['topicId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.saved,
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          // Statistics and test history (ST-15)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
