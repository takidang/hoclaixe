import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/equal_height_grid.dart';
import '../../exam/data/exam_session_repository.dart';
import '../../study/data/study_providers.dart';
import '../../study/domain/study_topic.dart';
import '../../study/presentation/topic_title.dart';
import '../data/stats_providers.dart';
import 'activity_card.dart';

/// Tab "Thống kê" (ST-15): answers per day (chart), test numbers, progress per topic, test history (tap → review), frequent mistakes.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(examHistoryProvider).value ?? const [];
    final topics = ref.watch(topicListProvider).value ?? const [];
    final chapters = ref.watch(contentProvider).value?.chapters ?? const {};
    final stats = testStats(history);
    final activity = ref.watch(activityProvider).value;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.statistics)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 16,
        ),
        children: [
          if (activity != null) ...[
            ActivityCard(days: activity),
            const SizedBox(height: 12),
          ],
          EqualHeightGrid(
            columns: 3,
            spacing: 8,
            children: [
              _Number(label: S.testsTaken, value: '${stats.taken}'),
              _Number(
                label: S.passRate,
                value: stats.taken == 0
                    ? '–'
                    : S.percent(stats.passRatePercent),
              ),
              _Number(
                label: S.latestScore,
                value: stats.latest == null
                    ? '–'
                    : S.scoreOf(stats.latest!.score, stats.latest!.total),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.trending_down),
              title: const Text(S.frequentWrong),
              subtitle: const Text(S.frequentWrongHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push(Routes.studyTopic(StudyTopic.frequentId)),
            ),
          ),
          const SizedBox(height: 20),
          Text(S.topicProgress, style: text.titleMedium),
          const SizedBox(height: 8),
          for (final (topic, s) in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topicTitle(topic, chapters),
                          style: text.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.percent((100 * s.progress).round()),
                        style: text.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: s.progress,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(S.testHistory, style: text.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(S.noTestsYet, style: text.bodyMedium),
            ),
          for (final h in history) _HistoryTile(entry: h),
        ],
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: text.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final ExamHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final answer = AnswerColors.of(context);
    final color = entry.passed ? answer.correct : answer.wrong;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          entry.passed ? Icons.verified : Icons.cancel_outlined,
          color: color,
        ),
        title: Text(S.historyTitle(entry.fixedSetNo)),
        subtitle: Text(S.historyDate(entry.submittedAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              S.scoreOf(entry.score, entry.total),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              entry.passed ? S.passedShort : S.failedShort,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: color),
            ),
          ],
        ),
        onTap: () => context.push(Routes.examReview(entry.sessionId)),
      ),
    );
  }
}
