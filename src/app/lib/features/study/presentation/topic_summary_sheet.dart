import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../domain/study_topic.dart';

enum SummaryAction { reviewWrong, restart, back }

/// End of a topic (ST-06 AC4): correct/wrong of this round and what to do next.
Future<SummaryAction?> showTopicSummary(
  BuildContext context, {
  required RoundSummary summary,
  required bool canRestart,
}) => showModalBottomSheet<SummaryAction>(
  context: context,
  showDragHandle: true,
  builder: (context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.topicFinished,
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              S.roundResult(summary.correct, summary.wrong, summary.total),
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (summary.wrong > 0) ...[
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, SummaryAction.reviewWrong),
                child: const Text(S.reviewTopicWrong),
              ),
              const SizedBox(height: 8),
            ],
            if (canRestart) ...[
              OutlinedButton(
                onPressed: () => Navigator.pop(context, SummaryAction.restart),
                child: const Text(S.restartTopic),
              ),
              const SizedBox(height: 8),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context, SummaryAction.back),
              child: const Text(S.backToTopics),
            ),
          ],
        ),
      ),
    );
  },
);
