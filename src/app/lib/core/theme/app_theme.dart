import 'package:flutter/material.dart';

/// Design v2 (30/10/2026, docs/design/DESIGN.md): dark by default, pastel gradient cards with real road signs
/// from the catalog, a floating tab bar; the lane line of v1 stays as the progress mark (every question learned
/// well is one more painted segment). Be Vietnam Pro for text, JetBrains Mono for standalone numbers.
/// Widgets read colours and text styles from Theme.of(context) and [AppGradients], never hard-code them:
/// the team can restyle the whole app by editing this file only.
abstract final class AppTheme {
  static const signBlue = Color(0xFF0B4F8C);
  static const signAmber = Color(0xFFF2A900);
  static const signRed = Color(0xFFC62828);
  static const fontFamily = 'BeVietnamPro';
  static const monoFamily = 'JetBrainsMono';
  static const radius = 14.0;

  /// Large cards (gradient cards, panels).
  static const cardRadius = 26.0;

  /// Text and lines on the pastel gradient cards, in light and dark mode alike.
  static const ink = Color(0xFF15171A);

  /// Translucent white of the count chips and of the disc under a sign on the gradient cards.
  static const chipFill = Color(0xB3FFFFFF);
  static const badgeFill = Color(0xEBFFFFFF);

  /// Secondary text on the gradient cards ([ink] at 85 %: ≥ 4.5:1 even on the darkest end of [AppGradients.sky]).
  static const inkSoft = Color(0xD915171A);

  /// Text styles for content on a gradient card: the theme's styles carry the light text colour of dark mode,
  /// which would override [ink] on the pastel cards.
  static TextTheme cardText(BuildContext context) =>
      Theme.of(context).textTheme.apply(bodyColor: ink, displayColor: ink);

  /// [style] in the mono face, optionally recoloured. For standalone numbers only (not Vietnamese words).
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
      secondary: const Color(
        0xFFB83A86,
      ), // pink of the chart, dark enough for a light panel
      tertiary: const Color(0xFF8A5A00),
      tertiaryContainer: const Color(0xFFFFE08A),
      onTertiaryContainer: const Color(0xFF2B1B00),
      error: signRed,
      surface: const Color(0xFFF2F3F5), // never pure white
      onSurface: ink,
      onSurfaceVariant: const Color(0xFF565C64),
      surfaceContainerLowest: const Color(0xFFFCFCFD), // panels
      outlineVariant: const Color(0xFFDADDE1),
      inverseSurface: const Color(0xFF1B1D1F), // tab bar
      onInverseSurface: const Color(0xFFF4F5F6),
    ),
    AnswerColors.light,
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: signBlue,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: const Color(0xFF7CC4FA),
      onPrimary: const Color(0xFF0B1E2B),
      primaryContainer: const Color(0xFF1D3A52),
      onPrimaryContainer: const Color(0xFFCFE8FD),
      secondary: const Color(0xFFF786D0),
      onSecondary: const Color(0xFF3A0F2C),
      tertiary: signAmber,
      tertiaryContainer: const Color(0xFF5A3F00),
      onTertiaryContainer: const Color(0xFFFFE08A),
      surface: const Color(0xFF1B1D1F),
      onSurface: const Color(0xFFF4F5F6),
      onSurfaceVariant: const Color(0xFFA5ABB3),
      surfaceContainerLowest: const Color(0xFF26292D),
      outlineVariant: const Color(0xFF34383D),
      inverseSurface: const Color(
        0xFFF4F5F6,
      ), // tab bar: light pill on the dark screen
      onInverseSurface: const Color(0xFF1B1D1F),
    ),
    AnswerColors.dark,
  );

  static ThemeData _build(ColorScheme scheme, AnswerColors answers) {
    final dark = scheme.brightness == Brightness.dark;
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
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
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
      extensions: [answers],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        // dark panels need no outline (design reference); light ones do, to stand off the canvas
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius - 6),
          side: dark
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
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

/// Pastel card gradients (same in light and dark mode; text on them is [AppTheme.ink]).
abstract final class AppGradients {
  static const _begin = Alignment.topLeft;
  static const _end = Alignment.bottomRight;
  static const sunset = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFFFD27A), Color(0xFFF7708F)],
  );
  static const sky = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFF9AD8FF), Color(0xFF8B8CF6)],
  );
  static const bloom = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFFBC2E6), Color(0xFFE07BEF)],
  );
  static const leaf = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFCFF5A0), Color(0xFF4FD1C5)],
  );
  static const amber = LinearGradient(
    begin: _begin,
    end: _end,
    colors: [Color(0xFFFFE38A), Color(0xFFFF9A5C)],
  );

  /// Cycled through lists of cards (topics).
  static const cycle = [sky, bloom, leaf, sunset, amber];
}

/// Motion tokens. Wrap durations in [of] so "remove animations" shows the end state at once.
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
