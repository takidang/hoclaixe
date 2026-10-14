import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/exam/data/exam_session_repository.dart';
import '../features/study/data/progress_repository.dart';
import 'clock.dart';
import 'content/content_repository.dart';
import 'content/models.dart';
import 'db/app_database.dart';

/// Read-only content (questions, test blueprints, signs), loaded once.
/// No automatic retry: bundled assets that fail to parse will not fix themselves — show the error screen.
final contentProvider = FutureProvider<ContentBundle>(
  (ref) => ContentRepository().load(),
  retry: _noRetry,
);

Duration? _noRetry(int retryCount, Object error) => null;

/// Current time; overridden in tests so they never depend on the real date.
final clockProvider = Provider<Clock>((ref) => systemClock);

/// Learner database; overridden in tests with an in-memory database.
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final progressRepositoryProvider = FutureProvider<ProgressRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return ProgressRepository(db.db, clock: ref.watch(clockProvider));
});

final examSessionRepositoryProvider = FutureProvider<ExamSessionRepository>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  return ExamSessionRepository(db.db, clock: ref.watch(clockProvider));
});
