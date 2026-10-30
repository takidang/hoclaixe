import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/lane_line.dart';
import '../data/home_summary_provider.dart';
import '../domain/home_summary.dart';

/// Home (FR-A04, ST-04; design v1): road card with the lane line, one "Thi thử" button, practice list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    ref.listen(
      homeSummaryProvider,
      (_, next) => _promptResume(context, ref, next.value),
    );
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
            tooltip: S.searchQuestions,
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.search),
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
    final blocks = [
      if (open != null)
        _ResumeCard(
          sessionId: open.id,
          remaining: open.remaining(ref.watch(clockProvider)()),
        ),
      _RoadCard(summary: summary),
      _ExamButton(summary: summary),
      _PracticeList(summary: summary),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _Entrance(index: i, child: blocks[i]),
        ],
      ],
    );
  }
}

/// Blocks fade and rise in one after another ([AppMotion.stagger]); instant with reduced motion.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const base = 360;
    final delay = index * AppMotion.stagger.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, Duration(milliseconds: base + delay)),
      curve: Interval(delay / (base + delay), 1, curve: AppMotion.quickCurve),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Signature: the learner's progress as a lane marking on asphalt, dashed until each question is right.
class _RoadCard extends StatelessWidget {
  const _RoadCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final road = RoadColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: road.asphalt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.studyProgress,
              style: text.labelLarge?.copyWith(color: road.onAsphaltVariant),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${summary.correctCount}',
                    style: AppTheme.mono(text.headlineLarge, road.marking),
                  ),
                  TextSpan(
                    text: S
                        .progressCount(summary.correctCount, summary.poolSize)
                        .substring('${summary.correctCount}'.length),
                    style: text.titleSmall?.copyWith(
                      color: road.onAsphaltVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LaneLine.progress(
              value: summary.progress,
              color: road.marking,
              thickness: 5,
              semanticsLabel: S.progressCount(
                summary.correctCount,
                summary.poolSize,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              S.progressHint,
              style: text.bodySmall?.copyWith(color: road.onAsphaltVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// The one main action of the screen.
class _ExamButton extends StatelessWidget {
  const _ExamButton({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final on = Theme.of(context).colorScheme.onPrimary;
    final s = summary.structure;
    return FilledButton(
      onPressed: () => context.push(Routes.exam),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.practiceExam,
                  style: text.titleMedium?.copyWith(color: on),
                ),
                if (s != null)
                  Text(
                    S.examCta(
                      summary.licenseClass,
                      s.questionCount,
                      s.durationMinutes,
                    ),
                    style: text.bodySmall?.copyWith(
                      color: on.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward, color: on),
        ],
      ),
    );
  }
}

class _PracticeList extends StatelessWidget {
  const _PracticeList({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final rows = [
      const _PracticeRow(
        icon: Icons.menu_book_outlined,
        label: S.studyByTopic,
        detail: S.studyByTopicHint,
        route: Routes.study,
      ),
      _PracticeRow(
        icon: Icons.warning_amber_rounded,
        label: S.criticalQuestions,
        detail: S.criticalHint(summary.criticalCount),
        route: Routes.critical,
        caution: true,
      ),
      _PracticeRow(
        icon: Icons.replay,
        label: S.reviewWrong,
        detail: S.wrongHint(summary.wrongCount),
        route: Routes.wrong,
      ),
      _PracticeRow(
        icon: Icons.bookmark_border,
        label: S.savedQuestions,
        detail: S.questionCount(summary.savedCount),
        route: Routes.saved,
      ),
      const _PracticeRow(
        icon: Icons.signpost_outlined,
        label: S.trafficSigns,
        detail: S.signsHint,
        route: Routes.signs,
      ),
      const _PracticeRow(
        icon: Icons.insights_outlined,
        label: S.statistics,
        detail: S.statsHint,
        route: Routes.stats,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            S.practiceSection,
            style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(indent: 72),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PracticeRow extends StatelessWidget {
  const _PracticeRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.route,
    this.caution = false,
  });

  final IconData icon;
  final String label;
  final String detail;
  final String route;

  /// Critical questions: warning-sign yellow instead of the primary tone.
  final bool caution;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: caution
                    ? scheme.tertiaryContainer
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(
                  icon,
                  size: 22,
                  color: caution
                      ? scheme.onTertiaryContainer
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleSmall),
                  Text(
                    detail,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
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

/// Asked once, when the app opens with an unfinished test (ST-09 AC3). A test past its deadline is opened
/// directly: the exam screen submits it and shows the result (FR-A25).
class _ResumePrompt {
  bool shown = false;
}

final _resumePromptProvider = Provider<_ResumePrompt>((ref) => _ResumePrompt());

Future<void> _promptResume(
  BuildContext context,
  WidgetRef ref,
  HomeSummary? summary,
) async {
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
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(S.later),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(S.resume),
        ),
      ],
    ),
  );
  if (resume == true && context.mounted) {
    await context.push(Routes.examSession(open.id));
  }
}
