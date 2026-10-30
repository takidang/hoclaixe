import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/equal_height_grid.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/lane_line.dart';
import '../data/home_summary_provider.dart';
import '../domain/home_summary.dart';

/// Signs from the catalog that illustrate the home cards (decorative; chosen for their meaning).
abstract final class _Signs {
  static const lanes =
      'R.411'; // Hướng đi trên mỗi làn đường phải theo: the learner's lane
  static const speed = 'R.306'; // Tốc độ tối thiểu cho phép: a timed test
  static const danger = 'W.233'; // Nguy hiểm khác: critical questions
  static const detour =
      'R.302a'; // Hướng phải đi vòng chướng ngại vật: going back over mistakes
  static const noEntry = 'P.102'; // Cấm đi ngược chiều: the best-known sign
}

/// Tab "Tổng quan" (FR-A04, ST-04; design v2): progress card with the lane line, "Thi thử", critical
/// questions, wrong answers and the sign catalog as gradient cards.
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
    final scheme = Theme.of(context).colorScheme;
    final round = IconButton.styleFrom(
      backgroundColor: scheme.surfaceContainerLowest,
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(color: scheme.onSurface),
        title: Text(cls == null ? S.appName : S.className(cls)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: scheme.surfaceContainerLowest,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => context.push(Routes.licenseClass),
            child: const Text(S.changeClass),
          ),
          const SizedBox(width: 6),
          IconButton(
            style: round,
            tooltip: S.searchQuestions,
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.search),
          ),
          IconButton(
            style: round,
            tooltip: S.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(Routes.about),
          ),
          const SizedBox(width: 8),
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
      _ProgressCard(summary: summary),
      _ExamCard(summary: summary),
      EqualHeightGrid(
        columns: 2,
        spacing: 12,
        children: [
          _FeatureCard(
            gradient: AppGradients.amber,
            sign: _Signs.danger,
            label: S.criticalQuestions,
            detail: S.criticalHint(summary.criticalCount),
            route: Routes.critical,
          ),
          _FeatureCard(
            gradient: AppGradients.bloom,
            sign: _Signs.detour,
            label: S.reviewWrong,
            detail: S.wrongHint(summary.wrongCount),
            route: Routes.wrong,
          ),
        ],
      ),
      const _FeatureCard(
        wide: true,
        gradient: AppGradients.leaf,
        sign: _Signs.noEntry,
        label: S.trafficSigns,
        detail: S.signsHint,
        route: Routes.signs,
      ),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
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

/// The learner's progress: a lane marking, dashed until each question is answered right (kept from v1).
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final count = '${summary.correctCount}';
    return GradientCard(
      gradient: AppGradients.sunset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.studyProgress, style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: count,
                            style: AppTheme.mono(
                              text.headlineLarge,
                              AppTheme.ink,
                            ),
                          ),
                          TextSpan(
                            text: S
                                .progressCount(
                                  summary.correctCount,
                                  summary.poolSize,
                                )
                                .substring(count.length),
                            style: text.titleSmall?.copyWith(
                              color: AppTheme.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SignBadge(code: _Signs.lanes),
            ],
          ),
          const SizedBox(height: 16),
          LaneLine.progress(
            value: summary.progress,
            color: AppTheme.ink,
            thickness: 5,
            semanticsLabel: S.progressCount(
              summary.correctCount,
              summary.poolSize,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            S.progressHint,
            style: text.bodySmall?.copyWith(color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// The main action of the tab.
class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final s = summary.structure;
    return GradientCard(
      gradient: AppGradients.sky,
      onTap: () => context.push(Routes.exam),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.practiceExam, style: text.headlineSmall),
                if (s != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    S.examCta(
                      summary.licenseClass,
                      s.questionCount,
                      s.durationMinutes,
                    ),
                    style: text.bodyMedium?.copyWith(color: AppTheme.inkSoft),
                  ),
                ],
              ],
            ),
          ),
          const SignBadge(code: _Signs.speed),
        ],
      ),
    );
  }
}

/// A gradient card that opens a feature: sign above the text when [wide] is false (half width),
/// beside it when true (full width).
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.gradient,
    required this.sign,
    required this.label,
    required this.detail,
    required this.route,
    this.wide = false,
  });

  final Gradient gradient;
  final String sign;
  final String label;
  final String detail;
  final String route;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: wide ? text.titleLarge : text.titleMedium),
        const SizedBox(height: 2),
        Text(detail, style: text.bodySmall?.copyWith(color: AppTheme.inkSoft)),
      ],
    );
    return GradientCard(
      gradient: gradient,
      padding: EdgeInsets.all(wide ? 20 : 16),
      onTap: () => context.push(route),
      child: wide
          ? Row(
              children: [
                Expanded(child: words),
                SignBadge(code: sign, size: 56),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignBadge(code: sign, size: 52),
                const SizedBox(height: 20),
                words,
              ],
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
