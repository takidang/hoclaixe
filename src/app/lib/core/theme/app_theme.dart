import 'package:flutter/material.dart';

/// Design system v0 (ST-13, 21/10/2026): colours taken from Vietnamese road signs (QCVN 41:2024) —
/// guide-sign blue as primary, warning-sign amber as tertiary, prohibition red as error — font Be Vietnam Pro,
/// thin outlined cards instead of shadows, 12 px radius, 8 px spacing grid.
/// Widgets must read colours and text styles from Theme.of(context), never hard-code them: the team can
/// restyle the whole app by editing this file only.
abstract final class AppTheme {
  static const signBlue = Color(0xFF0B4F8C);
  static const signAmber = Color(0xFFF2A900);
  static const signRed = Color(0xFFC62828);
  static const fontFamily = 'BeVietnamPro';
  static const radius = 12.0;

  static ThemeData light() => _build(
        ColorScheme.fromSeed(
          seedColor: signBlue,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          primary: signBlue,
          // light tonal container: 'fidelity' puts it too close to the seed, dark text became unreadable
          primaryContainer: const Color(0xFFD3E4F8),
          onPrimaryContainer: const Color(0xFF062C52),
          tertiary: const Color(0xFF8A5A00),
          tertiaryContainer: const Color(0xFFFFE08A),
          onTertiaryContainer: const Color(0xFF2B1B00),
          error: signRed,
          surface: const Color(0xFFF6F8FB),
          surfaceContainerLowest: Colors.white,
        ),
        AnswerColors.light,
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: signBlue,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ).copyWith(
          tertiary: signAmber,
          tertiaryContainer: const Color(0xFF5A3F00),
          onTertiaryContainer: const Color(0xFFFFE08A),
          surface: const Color(0xFF0F1720),
          surfaceContainerLowest: const Color(0xFF16202B),
        ),
        AnswerColors.dark,
      );

  static ThemeData _build(ColorScheme scheme, AnswerColors answers) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final base = ThemeData(colorScheme: scheme, fontFamily: fontFamily, useMaterial3: true);
    final text = base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [answers],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface, fontSize: 19),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: shape.copyWith(side: BorderSide(color: scheme.outlineVariant)),
      ),
      listTileTheme: ListTileThemeData(shape: shape),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: shape,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48), shape: shape),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer.withValues(alpha: 0.5),
        linearMinHeight: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surface, surfaceTintColor: Colors.transparent, shape: shape),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
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
