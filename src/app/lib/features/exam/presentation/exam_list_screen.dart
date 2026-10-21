import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/exam_providers.dart';

/// "Thi thử" (ST-11, FR-A20b): a random test or one of the 20 fixed sets with its latest result.
class ExamListScreen extends ConsumerWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(fixedResultsProvider).value ?? const {};
    final total = ref.watch(currentStructureProvider).value?.questionCount ?? 0;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.practiceExam)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text(S.randomTest),
              subtitle: const Text(S.randomTestHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.examStart()),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(S.fixedTests, style: text.titleMedium)),
              Text(
                S.fixedDone(results.length, fixedSetCount),
                style: text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              for (var n = 1; n <= fixedSetCount; n++)
                _FixedSetTile(number: n, result: results[n], total: total),
            ],
          ),
        ],
      ),
    );
  }
}

class _FixedSetTile extends StatelessWidget {
  const _FixedSetTile({required this.number, required this.result, required this.total});

  final int number;
  final ({int score, bool passed})? result;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final answer = AnswerColors.of(context);
    final r = result;
    final (String status, Color? color) = switch (r) {
      null => (S.notTaken, null),
      (passed: true, score: _) => (S.passedShort, answer.correct),
      _ => (S.failedShort, answer.wrong),
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.examStart(fixedSet: number)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.fixedTest(number), style: text.titleSmall),
              const SizedBox(height: 4),
              Text(status, style: text.labelMedium?.copyWith(color: color)),
              if (r != null)
                Text(
                  S.scoreOf(r.score, total),
                  style: text.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
