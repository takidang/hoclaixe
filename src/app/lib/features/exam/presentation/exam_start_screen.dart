import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../home/data/home_summary_provider.dart';
import '../data/exam_providers.dart';
import '../data/exam_session_repository.dart';
import '../domain/exam_generator.dart';

/// Test info before starting (ST-08 AC1): questions, time, pass mark, the critical-question rule.
class ExamStartScreen extends ConsumerStatefulWidget {
  const ExamStartScreen({super.key, this.fixedSet});

  /// 1…20 for a fixed set, null for a random test.
  final int? fixedSet;

  @override
  ConsumerState<ExamStartScreen> createState() => _ExamStartScreenState();
}

class _ExamStartScreenState extends ConsumerState<ExamStartScreen> {
  bool _starting = false;

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      final structure = (await ref.read(currentStructureProvider.future))!;
      final content = await ref.read(contentProvider.future);
      final repo = await ref.read(examSessionRepositoryProvider.future);
      const generator = ExamGenerator();
      final paper = widget.fixedSet == null
          ? generator.generate(
              structure: structure,
              bank: content.questions,
              random: Random(),
            )
          : generator.generateFixed(
              structure: structure,
              bank: content.questions,
              setNo: widget.fixedSet!,
              contentVersion: content.version,
            );
      try {
        final session = await repo.start(paper, structure);
        ref.invalidate(homeSummaryProvider);
        if (mounted) context.pushReplacement(Routes.examSession(session.id));
      } on OpenSessionExistsException {
        final open = await repo.openSession();
        if (open == null || !mounted) return;
        final choice = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(S.openTestExists),
            content: const Text(S.openTestExistsBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(S.abandonAndNew),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(S.continueTest),
              ),
            ],
          ),
        );
        if (!mounted || choice == null) return;
        if (choice) {
          context.pushReplacement(Routes.examSession(open.id));
        } else {
          await repo.abandon(open.id);
          await _start();
        }
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(S.examError)));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final structure = ref.watch(currentStructureProvider);
    final text = Theme.of(context).textTheme;
    final title = widget.fixedSet == null
        ? S.randomTest
        : S.fixedTest(widget.fixedSet!);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (structure) {
        AsyncData(value: final s?) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(S.testInfo, style: text.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _InfoRow(
                    label: S.questionsLabel,
                    value: S.questionCount(s.questionCount),
                  ),
                  _InfoRow(
                    label: S.durationLabel,
                    value: S.minutes(s.durationMinutes),
                  ),
                  _InfoRow(
                    label: S.passLabel,
                    value: S.correctAnswers(s.passScore),
                  ),
                  const _InfoRow(label: S.criticalRule, value: '', warning: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _starting ? null : _start,
              icon: const Icon(Icons.play_arrow),
              label: const Text(S.startTest),
            ),
          ],
        ),
        AsyncData() => const Center(child: Text(S.noStructure)),
        AsyncError() => const Center(child: Text(S.examError)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: warning
          ? Icon(Icons.warning_amber_rounded, color: scheme.error)
          : null,
      title: Text(
        label,
        style: warning ? TextStyle(color: scheme.error) : null,
      ),
      trailing: value.isEmpty
          ? null
          : Text(value, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
