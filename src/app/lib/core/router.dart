import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/home/presentation/coming_soon_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/license_class_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
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
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.study,
        builder: (context, state) => const TopicListScreen(),
        routes: [
          GoRoute(
            path: ':topicId',
            builder: (context, state) => StudyScreen(topicId: state.pathParameters['topicId']!),
          ),
        ],
      ),
      // Replaced by the real screens in ST-07, ST-08, ST-12.
      for (final (path, title) in [
        (Routes.exam, S.practiceExam),
        (Routes.wrong, S.reviewWrong),
        (Routes.critical, S.criticalQuestions),
        (Routes.signs, S.trafficSigns),
      ])
        GoRoute(path: path, builder: (context, state) => ComingSoonScreen(title: title)),
    ],
  );
});
