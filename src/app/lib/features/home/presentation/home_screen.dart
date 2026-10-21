import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/equal_height_grid.dart';
import '../data/home_summary_provider.dart';
import '../domain/home_summary.dart';

/// Home (FR-A04, ST-04): selected class, overall progress, feature tiles, resume an unfinished test.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    ref.listen(homeSummaryProvider, (_, next) => _promptResume(context, ref, next.value));
    final cls = summary.value?.licenseClass;
    return Scaffold(
      appBar: AppBar(
        title: Text(cls == null ? S.appName : S.className(cls)),
        actions: [
          TextButton(
            onPressed: () => context.push(Routes.licenseClass),
            child: const Text(S.changeClass),
          ),
          IconButton(
            tooltip: S.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(Routes.about),
          ),
        ],
      ),
      body: switch (summary) {
        AsyncData(value: final s?) => _HomeBody(summary: s),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(S.homeError, textAlign: TextAlign.center),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = summary.openSession;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (open != null) ...[
          _ResumeCard(
            sessionId: open.id,
            remaining: open.remaining(ref.watch(clockProvider)()),
          ),
          const SizedBox(height: 12),
        ],
        _ProgressCard(summary: summary),
        const SizedBox(height: 12),
        EqualHeightGrid(
          columns: 2,
          children: [
            const _FeatureTile(
              icon: Icons.menu_book_outlined,
              label: S.studyByTopic,
              route: Routes.study,
            ),
            const _FeatureTile(
              icon: Icons.timer_outlined,
              label: S.practiceExam,
              route: Routes.exam,
            ),
            _FeatureTile(
              icon: Icons.replay,
              label: S.reviewWrong,
              detail: S.questionCount(summary.wrongCount),
              route: Routes.wrong,
            ),
            _FeatureTile(
              icon: Icons.warning_amber_rounded,
              label: S.criticalQuestions,
              detail: S.questionCount(summary.criticalCount),
              route: Routes.critical,
              caution: true,
            ),
            const _FeatureTile(
              icon: Icons.signpost_outlined,
              label: S.trafficSigns,
              route: Routes.signs,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final on = scheme.onPrimary;
    return Card(
      color: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.studyProgress, style: text.titleSmall?.copyWith(color: on.withValues(alpha: 0.85))),
            const SizedBox(height: 4),
            Text(
              S.progressCount(summary.correctCount, summary.poolSize),
              style: text.headlineSmall?.copyWith(color: on, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: summary.progress,
              color: scheme.tertiaryContainer,
              backgroundColor: on.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(S.progressHint, style: text.bodySmall?.copyWith(color: on.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.sessionId, required this.remaining});

  final int sessionId;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: const Text(S.resumeExam),
        subtitle: Text(
          remaining == Duration.zero ? S.examTimeUp : S.timeLeft(remaining),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.examSession(sessionId)),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.route,
    this.detail,
    this.caution = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? detail;

  /// Critical questions: warning-sign amber instead of the primary tone.
  final bool caution;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: caution ? scheme.tertiaryContainer : scheme.primaryContainer,
                foregroundColor: caution ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
                child: Icon(icon, size: 22),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleSmall),
                  if (detail != null) Text(detail!, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asked once, when the app opens with an unfinished test (ST-09 AC3). A test past its deadline is opened
/// directly: the exam screen submits it and shows the result (FR-A25).
class _ResumePrompt {
  bool shown = false;
}

final _resumePromptProvider = Provider<_ResumePrompt>((ref) => _ResumePrompt());

Future<void> _promptResume(BuildContext context, WidgetRef ref, HomeSummary? summary) async {
  final prompt = ref.read(_resumePromptProvider);
  // decided once, on the first home data after start — not when coming back from "Lưu tạm và thoát"
  if (summary == null || prompt.shown) return;
  prompt.shown = true;
  final open = summary.openSession;
  if (open == null) return;
  final left = open.remaining(ref.read(clockProvider)());
  if (left == Duration.zero) {
    await context.push(Routes.examSession(open.id));
    return;
  }
  final resume = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(S.resumePromptTitle),
      content: Text(S.resumePromptBody(open.paper.licenseClass, left)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(S.later)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text(S.resume)),
      ],
    ),
  );
  if (resume == true && context.mounted) await context.push(Routes.examSession(open.id));
}

