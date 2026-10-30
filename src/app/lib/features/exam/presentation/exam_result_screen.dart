import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/lane_line.dart';
import '../data/exam_providers.dart';
import '../domain/exam_grader.dart';
import '../domain/exam_session.dart';

/// Result of a submitted test (ST-10 AC1). Graded again from the answers stored in the database,
/// so it always matches what was submitted (AC3).
class ExamResultScreen extends ConsumerWidget {
  const ExamResultScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(examViewProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text(S.resultTitle)),
      body: switch (view) {
        AsyncData(value: final v?)
            when v.session.status == ExamStatus.submitted =>
          _ResultBody(view: v, result: v.submittedResult()),
        AsyncData(value: final _?) => const Center(child: Text(S.notSubmitted)),
        AsyncData() || AsyncError() => const Center(child: Text(S.examError)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.view, required this.result});

  final ExamView view;
  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final answer = AnswerColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = result.passed ? answer.correct : answer.wrong;
    final score = '${result.score}';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          result.passed ? S.passed : S.failed,
          style: text.headlineMedium?.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: score,
                style: AppTheme.mono(text.displaySmall, scheme.onSurface),
              ),
              TextSpan(
                text: S
                    .resultScore(result.score, result.total)
                    .substring(score.length),
                style: text.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // one segment per question: the whole test at a glance (design v1 signature)
        LaneLine.segments(
          marks: [
            for (final c in result.correctByPosition)
              switch (c) {
                true => LaneMark.done,
                false => LaneMark.wrong,
                null => LaneMark.empty,
              },
          ],
          color: answer.correct,
          wrongColor: answer.wrong,
          semanticsLabel: S.resultCounts(
            result.correct,
            result.wrong,
            result.unanswered,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.resultLaneHint,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Text(
          S.resultCounts(result.correct, result.wrong, result.unanswered),
          style: text.bodyMedium,
        ),
        Text(
          S.passMark(result.passScore),
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final reason in result.failReasons)
          Card(
            margin: const EdgeInsets.only(bottom: 8), // aligned with the buttons below
            color: answer.wrongContainer,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: answer.wrong),
              title: Text(switch (reason) {
                FailReason.notEnoughScore => S.failNotEnough(
                  result.score,
                  result.passScore,
                ),
                FailReason.wrongCritical => S.failCritical,
              }),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push(Routes.examReview(view.session.id)),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text(S.reviewTest),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.go(Routes.exam),
          child: const Text(S.anotherTest),
        ),
        TextButton(
          onPressed: () => context.go(Routes.home),
          child: const Text(S.backHome),
        ),
      ],
    );
  }
}
