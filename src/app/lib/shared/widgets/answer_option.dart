import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';

/// How one option is drawn; decided by QuestionView from the mode and the learner's choice.
enum AnswerState {
  /// Selectable, not chosen.
  idle,

  /// Chosen in exam mode (no correctness shown).
  chosen,

  /// The correct option, revealed (study / review).
  correct,

  /// The learner's wrong choice, revealed (study / review).
  wrong,

  /// Revealed but neither correct nor chosen.
  dimmed,
}

/// One numbered answer option (1–4, like the official test software).
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
  });

  final int index;
  final String text;
  final AnswerState state;

  /// Null = locked.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answer = AnswerColors.of(context);
    final (
      Color? background,
      Color border,
      Color badge,
      Color onBadge,
      IconData? icon,
    ) = switch (state) {
      AnswerState.idle => (
        null,
        scheme.outlineVariant,
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        null,
      ),
      AnswerState.chosen => (
        scheme.primaryContainer,
        scheme.primary,
        scheme.primary,
        scheme.onPrimary,
        null,
      ),
      AnswerState.correct => (
        answer.correctContainer,
        answer.correct,
        answer.correct,
        answer.onCorrect,
        Icons.check,
      ),
      AnswerState.wrong => (
        answer.wrongContainer,
        answer.wrong,
        answer.wrong,
        answer.onWrong,
        Icons.close,
      ),
      AnswerState.dimmed => (
        null,
        scheme.outlineVariant,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        null,
      ),
    };
    final number = index + 1;
    final stateLabel = switch (state) {
      AnswerState.chosen => S.answerChosen,
      AnswerState.correct => S.answerCorrect,
      AnswerState.wrong => S.answerWrong,
      _ => null,
    };
    return Semantics(
      button: onTap != null,
      selected: state == AnswerState.chosen,
      label: [S.answerLabel(number), text, ?stateLabel].join('. '),
      excludeSemantics: true,
      child: Material(
        // panel colour so options stand out from the canvas (design v1)
        color: background ?? scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: border,
            width: state == AnswerState.idle || state == AnswerState.dimmed
                ? 1
                : 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // a key of the test machine: square, mono digit; colour eases in when revealed
                  AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.quick),
                    curve: AppMotion.quickCurve,
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badge,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: icon == null
                        ? Text(
                            '$number',
                            style: AppTheme.mono(
                              Theme.of(context).textTheme.labelLarge,
                              onBadge,
                            ),
                          )
                        : Icon(icon, size: 18, color: onBadge),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: state == AnswerState.dimmed
                            ? scheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
