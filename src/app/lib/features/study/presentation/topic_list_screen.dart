import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../data/study_providers.dart';
import '../domain/study_topic.dart';
import 'topic_title.dart';

/// "Học theo chủ đề" (FR-A10): all questions, critical questions, then chapters, each with progress.
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
          padding: const EdgeInsets.all(16),
          itemCount: value.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final (topic, stats) = value[i];
            return _TopicCard(
              title: topicTitle(topic, chapters),
              stats: stats,
              onTap: () => context.push(Routes.studyTopic(topic.id)),
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
    required this.title,
    required this.stats,
    required this.onTap,
  });

  final String title;
  final TopicStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(title, style: text.titleMedium)),
                  const SizedBox(width: 8),
                  Text(S.questionCount(stats.total), style: text.labelLarge),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: stats.progress),
              const SizedBox(height: 6),
              Text(
                S.topicStats(stats.correct, stats.wrong, stats.notDone),
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
