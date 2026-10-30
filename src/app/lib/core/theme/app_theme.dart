import 'package:flutter/material.dart';

/// Design v1 "Vạch kẻ đường" (30/10/2026, docs/design/DESIGN.md): every question learned well is one more
/// painted segment of a lane line. Colours from the road and from Vietnamese guide signs (QCVN 41:2024);
/// Be Vietnam Pro for text, JetBrains Mono for numbers, timer and question labels.
/// Widgets read colours and text styles from Theme.of(context) and [RoadColors], never hard-code them:
/// the team can restyle the whole app by editing this file only.
abstract final class AppTheme {
  static const signBlue = Color(0xFF0B4F8C);
  static const signAmber = Color(0xFFF2A900);
  static const signRed = Color(0xFFC62828);
  static const fontFamily = 'BeVietnamPro';
  static const monoFamily = 'JetBrainsMono';
  static const radius = 12.0;

  /// [style] in the mono face, optionally recoloured. For numbers and short labels only.
  static TextStyle? mono(TextStyle? style, [Color? color]) => style?.copyWith(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w500,
    color: color,
    letterSpacing: 0,
  );

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
      surface: const Color(
        0xFFF2F4F6,
      ), // canvas: asphalt-tinted, never pure white
      onSurface: const Color(0xFF141B22),
      onSurfaceVariant: const Color(0xFF535E69),
      surfaceContainerLowest: const Color(0xFFFBFCFD), // panel
      outlineVariant: const Color(0xFFD9DEE3),
    ),
    AnswerColors.light,
    RoadColors.light,
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: signBlue,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: const Color(0xFF8CBCEB),
      onPrimary: const Color(0xFF062C52),
      primaryContainer: const Color(0xFF1E3A57),
      onPrimaryContainer: const Color(0xFFD3E4F8),
      tertiary: signAmber,
      tertiaryContainer: const Color(0xFF5A3F00),
      onTertiaryContainer: const Color(0xFFFFE08A),
      surface: const Color(0xFF0F1419),
      onSurface: const Color(0xFFE7ECF0),
      onSurfaceVariant: const Color(0xFFA4AFBA),
      surfaceContainerLowest: const Color(0xFF171E25),
      outlineVariant: const Color(0xFF2C3640),
    ),
    AnswerColors.dark,
    RoadColors.dark,
  );

  static ThemeData _build(
    ColorScheme scheme,
    AnswerColors answers,
    RoadColors road,
  ) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final base = ThemeData(
      colorScheme: scheme,
      fontFamily: fontFamily,
      useMaterial3: true,
    );
    final t = base.textTheme;
    final text = t.copyWith(
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: t.bodyMedium?.copyWith(height: 1.45),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [answers, road],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 19,
        ),
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
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
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
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Motion tokens (design v1). Wrap durations in [of] so "remove animations" shows the end state at once.
abstract final class AppMotion {
  static const quick = Duration(milliseconds: 200);
  static const quickCurve = Curves.easeOutCubic;

  /// A lane segment being painted.
  static const paint = Duration(milliseconds: 700);
  static const paintCurve = Cubic(0.2, 0, 0, 1);

  /// Delay between blocks appearing one after another on the home screen.
  static const stagger = Duration(milliseconds: 80);

  static Duration of(BuildContext context, Duration d) =>
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      ? Duration.zero
      : d;
}

/// Road surface colours for the signature lane line (not part of ColorScheme). `RoadColors.of(context)`.
@immutable
class RoadColors extends ThemeExtension<RoadColors> {
  const RoadColors({
    required this.asphalt,
    required this.onAsphaltVariant,
    required this.marking,
    required this.markingYellow,
  });

  static const light = RoadColors(
    asphalt: Color(0xFF2A3139),
    onAsphaltVariant: Color(0xFFB9C2CB),
    marking: Color(0xFFF1F3F5),
    markingYellow: Color(0xFFF2C230),
  );

  static const dark = RoadColors(
    asphalt: Color(0xFF232B33),
    onAsphaltVariant: Color(0xFFAEB8C2),
    marking: Color(0xFFE9EDF0),
    markingYellow: Color(0xFFF2C230),
  );

  final Color asphalt;

  /// Secondary text on [asphalt].
  final Color onAsphaltVariant;

  /// White road paint, also the main text colour on [asphalt].
  final Color marking;

  /// Critical questions, like warning-sign yellow.
  final Color markingYellow;

  static RoadColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<RoadColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  RoadColors copyWith({
    Color? asphalt,
    Color? onAsphaltVariant,
    Color? marking,
    Color? markingYellow,
  }) => RoadColors(
    asphalt: asphalt ?? this.asphalt,
    onAsphaltVariant: onAsphaltVariant ?? this.onAsphaltVariant,
    marking: marking ?? this.marking,
    markingYellow: markingYellow ?? this.markingYellow,
  );

  @override
  RoadColors lerp(RoadColors? other, double t) => other == null
      ? this
      : RoadColors(
          asphalt: Color.lerp(asphalt, other.asphalt, t)!,
          onAsphaltVariant: Color.lerp(
            onAsphaltVariant,
            other.onAsphaltVariant,
            t,
          )!,
          marking: Color.lerp(marking, other.marking, t)!,
          markingYellow: Color.lerp(markingYellow, other.markingYellow, t)!,
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
