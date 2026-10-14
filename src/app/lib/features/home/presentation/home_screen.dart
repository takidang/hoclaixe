import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../data/home_summary_provider.dart';
import '../domain/home_summary.dart';

/// Home (FR-A04, ST-04): selected class, overall progress, feature tiles, resume an unfinished test.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
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
          _ResumeCard(remaining: open.remaining(ref.watch(clockProvider)())),
          const SizedBox(height: 12),
        ],
        _ProgressCard(summary: summary),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(S.studyProgress, style: text.titleMedium)),
                Text(
                  S.progressCount(summary.correctCount, summary.poolSize),
                  style: text.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: summary.progress),
            const SizedBox(height: 8),
            Text(S.progressHint, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.remaining});

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
        onTap: () => context.push(Routes.exam),
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
  });

  final IconData icon;
  final String label;
  final String route;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleSmall),
                  if (detail != null) Text(detail!, style: text.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
