import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../exam/data/exam_session_repository.dart';
import '../domain/daily_activity.dart';

/// Submitted tests of the selected class, newest first (FR-A29).
final examHistoryProvider = FutureProvider<List<ExamHistoryEntry>>((ref) async {
  final licenseClass = (await ref.watch(settingsProvider.future)).licenseClass;
  if (licenseClass == null) return const [];
  final repo = await ref.watch(examSessionRepositoryProvider.future);
  return repo.history(licenseClass);
});

/// Answers per day over the last 30 days (activity chart). Invalidated whenever answers are recorded.
final activityProvider = FutureProvider<List<DayActivity>>((ref) async {
  final repo = await ref.watch(progressRepositoryProvider.future);
  final today = ref.read(clockProvider)();
  const days = 30;
  final since = DateTime(today.year, today.month, today.day - (days - 1));
  return dailyActivity(await repo.answerTimes(since), today: today, days: days);
});

/// Test numbers for the statistics card (FR-A50). Pure function of the history.
({int taken, int passRatePercent, ExamHistoryEntry? latest}) testStats(
  List<ExamHistoryEntry> history,
) => (
  taken: history.length,
  passRatePercent: history.isEmpty
      ? 0
      : (100 * history.where((h) => h.passed).length / history.length).round(),
  latest: history.firstOrNull,
);
