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
          itemCount: value.length + 1,
          separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 4 : 12),
          itemBuilder: (context, row) {
            if (row == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  S.holdForActions,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final i = row - 1;
            final (topic, stats) = value[i];
            // only the first screenful staggers in; later cards are built while scrolling and appear at once
            return Entrance(
              index: i < 6 ? i : 0,
              child: _TopicCard(
                tone: CardTone.cycle[i % CardTone.cycle.length],
                title: topicTitle(topic, chapters),
                stats: stats,
                onTap: () => context.push(Routes.studyTopic(topic.id)),
                onLongPress: () => _showTopicActions(
                  context,
                  ref,
                  topic: topic,
                  title: topicTitle(topic, chapters),
                  stats: stats,
                ),
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

/// Press and hold a topic: continue, review its wrong answers, or start it over.
Future<void> _showTopicActions(
  BuildContext context,
  WidgetRef ref, {
  required StudyTopic topic,
  required String title,
  required TopicStats stats,
}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true, // above the tab bar
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow_rounded),
            title: const Text(S.continueStudy),
            onTap: () => Navigator.pop(context, 'continue'),
          ),
          if (stats.wrong > 0)
            ListTile(
              leading: const Icon(Icons.replay),
              title: const Text(S.reviewTopicWrong),
              onTap: () => Navigator.pop(context, 'wrong'),
            ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text(S.restartFromStart),
            subtitle: const Text(S.restartTopicHint),
            onTap: () => Navigator.pop(context, 'restart'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  if (action == 'restart') {
    final cls = (await ref.read(classPoolProvider.future))?.licenseClass;
    if (cls == null) return;
    final repo = await ref.read(progressRepositoryProvider.future);
    await repo.restartRound(cls, topic.id);
    await repo.saveTopicPosition(cls, topic.id, topic.questions.first.id);
    ref.invalidate(topicListProvider);
  }
  if (!context.mounted) return;
  await context.push(
    Routes.studyTopic(
      action == 'wrong' ? StudyTopic.wrongOf(topic.id) : topic.id,
    ),
  );
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.tone,
    required this.title,
    required this.stats,
    required this.onTap,
    required this.onLongPress,
  });

  final CardTone tone;
  final String title;
  final TopicStats stats;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.cardText(context);
    return GradientCard(
      tone: tone,
      onTap: onTap,
      onLongPress: onLongPress,
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
