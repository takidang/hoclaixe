import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
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
          _ResultBody(view: v, result: v.grade(v.session.answers)),
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
    final color = result.passed ? answer.correct : answer.wrong;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          result.passed ? Icons.verified : Icons.cancel_outlined,
          size: 72,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          result.passed ? S.passed : S.failed,
          style: text.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          S.resultScore(result.score, result.total),
          style: text.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          S.resultCounts(result.correct, result.wrong, result.unanswered),
          style: text.bodyMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          S.passMark(result.passScore),
          style: text.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        for (final reason in result.failReasons)
          Card(
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
