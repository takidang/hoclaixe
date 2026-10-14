import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../domain/study_topic.dart';

enum SummaryAction { reviewWrong, restart, back }

/// End of a topic (ST-06 AC4): correct/wrong of this round and what to do next.
/// Wrong-list rounds always offer another round: a question leaves the list only after 2 correct answers in a row.
Future<SummaryAction?> showTopicSummary(
  BuildContext context, {
  required RoundSummary summary,
  required bool canRestart,
  required String reviewLabel,
  required bool alwaysOfferReview,
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
            if (alwaysOfferReview || summary.wrong > 0) ...[
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, SummaryAction.reviewWrong),
                child: Text(reviewLabel),
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
              child: const Text(S.goBack),
            ),
          ],
        ),
      ),
    );
  },
);
