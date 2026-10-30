import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/lane_line.dart';
import '../../../shared/widgets/motion.dart';
import '../data/study_providers.dart';
import '../domain/study_topic.dart';
import 'topic_title.dart';

/// Tab "Học" (FR-A10): all questions, critical questions, then chapters, each a gradient card with progress.
class TopicListScreen extends ConsumerWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicListProvider);
    final chapters = ref.watch(contentProvider).value?.chapters ?? const {};
    return Scaffold(
      appBar: AppBar(title: const Text(S.studyByTopic)),
      body: switch (topics) {
        AsyncData(:final value) => ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          itemCount: value.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final (topic, stats) = value[i];
            // only the first screenful staggers in; later cards are built while scrolling and appear at once
            return Entrance(
              index: i < 6 ? i : 0,
              child: _TopicCard(
                tone: CardTone.cycle[i % CardTone.cycle.length],
                title: topicTitle(topic, chapters),
                stats: stats,
                onTap: () => context.push(Routes.studyTopic(topic.id)),
              ),
            );
          },
        ),
        AsyncError() => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(S.studyError, textAlign: TextAlign.center),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.tone,
    required this.title,
    required this.stats,
    required this.onTap,
  });

  final CardTone tone;
  final String title;
  final TopicStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    return GradientCard(
      tone: tone,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountChip(
            icon: Icons.menu_book_outlined,
            label: S.questionCount(stats.total),
          ),
          const SizedBox(height: 16),
          Text(title, style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            S.topicStats(stats.correct, stats.wrong, stats.notDone),
            style: text.bodyMedium?.copyWith(
              color: CardPalette.of(context).inkSoft,
            ),
          ),
          const SizedBox(height: 14),
          LaneLine.progress(
            value: stats.progress,
            color: CardPalette.of(context).ink,
            semanticsLabel: S.topicStats(
              stats.correct,
              stats.wrong,
              stats.notDone,
            ),
          ),
        ],
      ),
    );
  }
}
