import 'package:flutter/material.dart';

/// Placeholder Material 3 theme — replaced by the design system made in Claude Design.
/// Widgets must read colors and text styles from Theme.of(context), never hard-code them.
abstract final class AppTheme {
  static const _seed = Color(0xFF0B5CAD);

  static ThemeData light() => ThemeData(
    colorSchemeSeed: _seed,
    brightness: Brightness.light,
    extensions: const [AnswerColors.light],
  );
  static ThemeData dark() => ThemeData(
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
    extensions: const [AnswerColors.dark],
  );
}

/// Correct / wrong answer colors (not part of ColorScheme). `AnswerColors.of(context)`.
@immutable
class AnswerColors extends ThemeExtension<AnswerColors> {
  const AnswerColors({
    required this.correct,
    required this.onCorrect,
    required this.correctContainer,
    required this.wrong,
    required this.onWrong,
    required this.wrongContainer,
  });

  static const light = AnswerColors(
    correct: Color(0xFF1B7F3B),
    onCorrect: Color(0xFFFFFFFF),
    correctContainer: Color(0xFFDDF3E2),
    wrong: Color(0xFFC62828),
    onWrong: Color(0xFFFFFFFF),
    wrongContainer: Color(0xFFFBE0E0),
  );

  static const dark = AnswerColors(
    correct: Color(0xFF7DD99A),
    onCorrect: Color(0xFF00391A),
    correctContainer: Color(0xFF1E3B27),
    wrong: Color(0xFFFF9C94),
    onWrong: Color(0xFF5C0A0A),
    wrongContainer: Color(0xFF4A2020),
  );

  final Color correct;
  final Color onCorrect;
  final Color correctContainer;
  final Color wrong;
  final Color onWrong;
  final Color wrongContainer;

  /// Falls back to the light/dark default when a theme (e.g. a test's MaterialApp) does not register it.
  static AnswerColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AnswerColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  AnswerColors copyWith({
    Color? correct,
    Color? onCorrect,
    Color? correctContainer,
    Color? wrong,
    Color? onWrong,
    Color? wrongContainer,
  }) => AnswerColors(
    correct: correct ?? this.correct,
    onCorrect: onCorrect ?? this.onCorrect,
    correctContainer: correctContainer ?? this.correctContainer,
    wrong: wrong ?? this.wrong,
    onWrong: onWrong ?? this.onWrong,
    wrongContainer: wrongContainer ?? this.wrongContainer,
  );

  @override
  AnswerColors lerp(AnswerColors? other, double t) => other == null
      ? this
      : AnswerColors(
          correct: Color.lerp(correct, other.correct, t)!,
          onCorrect: Color.lerp(onCorrect, other.onCorrect, t)!,
          correctContainer: Color.lerp(
            correctContainer,
            other.correctContainer,
            t,
          )!,
          wrong: Color.lerp(wrong, other.wrong, t)!,
          onWrong: Color.lerp(onWrong, other.onWrong, t)!,
          wrongContainer: Color.lerp(wrongContainer, other.wrongContainer, t)!,
        );
}
