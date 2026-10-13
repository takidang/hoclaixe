import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';

/// All routes (ADR-005). Redirects (disclaimer, chosen licence class, unfinished test) are added with those features.
final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
);
