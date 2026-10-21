import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/exam/presentation/exam_list_screen.dart';
import '../features/exam/presentation/exam_result_screen.dart';
import '../features/exam/presentation/exam_review_screen.dart';
import '../features/exam/presentation/exam_screen.dart';
import '../features/exam/presentation/exam_start_screen.dart';
import '../features/home/presentation/coming_soon_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/license_class_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/study/domain/study_topic.dart';
import '../features/study/presentation/study_screen.dart';
import '../features/study/presentation/topic_list_screen.dart';
import 'settings/app_settings.dart';
import 'strings.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const disclaimer = '/disclaimer';
  static const licenseClass = '/license';
  static const home = '/';
  static const about = '/about';
  static const study = '/study';
  static String studyTopic(String topicId) => '/study/$topicId';
  static const exam = '/exam';
  static String examStart({int? fixedSet}) => fixedSet == null ? '/exam/start' : '/exam/start?set=$fixedSet';
  static String examSession(int id) => '/exam/session/$id';
  static String examResult(int id) => '/exam/result/$id';
  static String examReview(int id) => '/exam/review/$id';
  static const wrong = '/wrong';
  static const critical = '/critical';
  static const signs = '/signs';
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
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        onboardingRedirect(ref.read(settingsProvider), state.uri.path),
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.disclaimer, builder: (context, state) => const DisclaimerScreen()),
      GoRoute(path: Routes.licenseClass, builder: (context, state) => const LicenseClassScreen()),
      // Features are children of home, so going straight to one (e.g. "Thi đề khác") keeps home below it.
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(path: 'about', builder: (context, state) => const AboutScreen()),
          GoRoute(
            path: 'study',
            builder: (context, state) => const TopicListScreen(),
            routes: [
              GoRoute(
                path: ':topicId',
                builder: (context, state) => StudyScreen(topicId: state.pathParameters['topicId']!),
              ),
            ],
          ),
          // Home tiles open the study screen directly (ST-07, FR-A41, FR-A42).
          GoRoute(
            path: 'wrong',
            builder: (context, state) => StudyScreen(topicId: StudyTopic.wrongOf(StudyTopic.allId)),
          ),
          GoRoute(path: 'critical', builder: (context, state) => const StudyScreen(topicId: StudyTopic.criticalId)),
          // Practice tests (ST-08 … ST-11)
          GoRoute(
            path: 'exam',
            builder: (context, state) => const ExamListScreen(),
            routes: [
              GoRoute(
                path: 'start',
                builder: (context, state) =>
                    ExamStartScreen(fixedSet: int.tryParse(state.uri.queryParameters['set'] ?? '')),
              ),
              GoRoute(
                path: 'session/:id',
                builder: (context, state) => ExamScreen(sessionId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'result/:id',
                builder: (context, state) => ExamResultScreen(sessionId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'review/:id',
                builder: (context, state) => ExamReviewScreen(sessionId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          // Replaced by the real screen in ST-12.
          GoRoute(path: 'signs', builder: (context, state) => const ComingSoonScreen(title: S.trafficSigns)),
        ],
      ),
    ],
  );
});
