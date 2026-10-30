import 'package:flutter/material.dart';

import '../../core/content/models.dart';
import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import 'answer_option.dart';
import 'image_zoom_page.dart';

/// Study (and review of wrong/critical questions), exam, or post-exam review.
enum QuestionMode {
  /// FR-A11: one choice, then correct/wrong is revealed and the question locks; critical badge shown.
  study,

  /// FR-A22/A23: choice can change, no correctness, no critical badge.
  exam,

  /// FR-A28: read-only, correctness and critical badge shown.
  review,
}

/// One question with its image and options, shared by study, exam and review screens (ST-05).
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.position,
    required this.licenseClass,
    required this.mode,
    this.selectedIndex,
    this.onSelect,
  });

  final Question question;

  /// 1-based order in the current topic or test (Q8: the big number; the official number is shown small).
  final int position;

  /// Decides the critical badge (critical questions differ per class).
  final String licenseClass;
  final QuestionMode mode;

  /// The learner's choice, null = none yet.
  final int? selectedIndex;

  /// Called with the option index; ignored when the question is locked.
  final ValueChanged<int>? onSelect;

  bool get _revealed => switch (mode) {
    QuestionMode.study => selectedIndex != null,
    QuestionMode.exam => false,
    QuestionMode.review => true,
  };

  bool get _locked => switch (mode) {
    QuestionMode.study => selectedIndex != null,
    QuestionMode.exam => false,
    QuestionMode.review => true,
  };

  AnswerState _stateOf(int i) {
    if (!_revealed) {
      return i == selectedIndex ? AnswerState.chosen : AnswerState.idle;
    }
    if (i == question.correctIndex) return AnswerState.correct;
    if (i == selectedIndex) return AnswerState.wrong;
    return AnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final showCritical =
        mode != QuestionMode.exam && question.isCriticalFor(licenseClass);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // wraps instead of overflowing with large system text (NFR-07)
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    S.questionNumber(position),
                    style: text.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (showCritical) const _CriticalBadge(),
                ],
              ),
            ),
            Text(
              S.officialNumber(question.number),
              style: text.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          question.content,
          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        for (final asset in question.images) ...[
          const SizedBox(height: 12),
          _QuestionImage(asset: asset),
        ],
        const SizedBox(height: 16),
        for (var i = 0; i < question.options.length; i++) ...[
          AnswerOption(
            index: i,
            text: question.options[i],
            state: _stateOf(i),
            onTap: _locked || onSelect == null ? null : () => onSelect!(i),
          ),
          const SizedBox(height: 8),
        ],
        if (mode == QuestionMode.review && selectedIndex == null)
          Text(
            S.notAnswered,
            style: text.bodyMedium?.copyWith(
              color: AnswerColors.of(context).wrong,
            ),
          ),
      ],
    );
  }
}

class _CriticalBadge extends StatelessWidget {
  const _CriticalBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          S.criticalBadge,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: S.zoomImage,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: () => ImageZoomPage.open(context, asset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        // Tall figures would push the options off screen; full size is one tap away.
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
