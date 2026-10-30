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

  /// White disc under a road sign on a card (sign pictures are JPEGs on white).
  static const badgeFill = Color(0xEBFFFFFF);

  /// Text on photos (under [photoScrim]) and the translucent fill of buttons placed on a photo.
  static const onPhoto = Color(0xFFF4F5F6);
  static const onPhotoFill = Color(0x33FFFFFF);

  /// Darkens the top of a photo under a light title (overview header).
  static const headerScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xB3000000), Color(0x00000000)],
  );

  /// Darkens the lower part of a photo so white text on it stays readable.
  static const photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x33000000), Color(0xE6000000)],
    stops: [0, 0.4, 1],
  );

  /// Text styles for content on a gradient card, in the card's [CardPalette.ink]: the theme's own styles
  /// carry the screen's text colour, which would override it.
  static TextTheme cardText(BuildContext context) {
    final ink = CardPalette.of(context).ink;
    return Theme.of(context).textTheme.apply(bodyColor: ink, displayColor: ink);
  }

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
      onSurface: const Color(0xFF15171A),
      onSurfaceVariant: const Color(0xFF565C64),
      surfaceContainerLowest: const Color(0xFFFCFCFD), // panels
      outlineVariant: const Color(0xFFDADDE1),
      inverseSurface: const Color(0xFF1B1D1F), // tab bar
      onInverseSurface: const Color(0xFFF4F5F6),
    ),
    AnswerColors.light,
    CardPalette.light,
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
      surface: const Color(
        0xFF111214,
      ), // deeper than v2's first try, so the jewel-tone cards glow
      onSurface: const Color(0xFFF4F5F6),
      onSurfaceVariant: const Color(0xFFA5ABB3),
      surfaceContainerLowest: const Color(0xFF1C1E22),
      outlineVariant: const Color(0xFF2B2E34),
      inverseSurface: const Color(
        0xFFF4F5F6,
      ), // tab bar: light pill on the dark screen
      onInverseSurface: const Color(0xFF1B1D1F),
    ),
    AnswerColors.dark,
    CardPalette.dark,
  );

  static ThemeData _build(
    ColorScheme scheme,
    AnswerColors answers,
    CardPalette cards,
  ) {
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
      extensions: [answers, cards],
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

/// The five card colours. Which gradient each one is depends on light / dark mode ([CardPalette]).
enum CardTone {
  sunset,
  sky,
  bloom,
  leaf,
  amber;

  /// Cycled through lists of cards (topics).
  static const cycle = [sky, bloom, leaf, sunset, amber];
}

/// Gradient cards: pastel with dark text in light mode, deep jewel tones with white text in dark mode
/// (design v2b, 30/10/2026). Text contrast measured ≥ 5:1 at both ends of every gradient, [inkSoft] included.
@immutable
class CardPalette extends ThemeExtension<CardPalette> {
  const CardPalette({
    required this.gradients,
    required this.ink,
    required this.inkSoft,
    required this.chipFill,
  });

  static LinearGradient _g(int a, int b) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(a), Color(b)],
  );

  static final light = CardPalette(
    gradients: {
      CardTone.sunset: _g(0xFFFFD27A, 0xFFF7708F),
      CardTone.sky: _g(0xFF9AD8FF, 0xFF8B8CF6),
      CardTone.bloom: _g(0xFFFBC2E6, 0xFFE07BEF),
      CardTone.leaf: _g(0xFFCFF5A0, 0xFF4FD1C5),
      CardTone.amber: _g(0xFFFFE38A, 0xFFFF9A5C),
    },
    ink: const Color(0xFF15171A),
    inkSoft: const Color(0xD915171A),
    chipFill: const Color(0xB3FFFFFF),
  );

  static final dark = CardPalette(
    gradients: {
      CardTone.sunset: _g(0xFFB43C0B, 0xFF9F1239),
      CardTone.sky: _g(0xFF1D4ED8, 0xFF6D28D9),
      CardTone.bloom: _g(0xFFA21CAF, 0xFF6D28D9),
      CardTone.leaf: _g(0xFF046C4E, 0xFF0E6A85),
      CardTone.amber: _g(0xFFA84D08, 0xFF9A3412),
    },
    ink: const Color(0xFFFFFFFF),
    inkSoft: const Color(0xEBFFFFFF),
    chipFill: const Color(0x2EFFFFFF),
  );

  final Map<CardTone, LinearGradient> gradients;

  /// Text, icons and the lane line on a card.
  final Color ink;

  /// Secondary text on a card.
  final Color inkSoft;

  /// Translucent fill of the count chips.
  final Color chipFill;

  LinearGradient operator [](CardTone tone) => gradients[tone]!;

  static CardPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CardPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  CardPalette copyWith({
    Map<CardTone, LinearGradient>? gradients,
    Color? ink,
    Color? inkSoft,
    Color? chipFill,
  }) => CardPalette(
    gradients: gradients ?? this.gradients,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    chipFill: chipFill ?? this.chipFill,
  );

  @override
  CardPalette lerp(CardPalette? other, double t) => other == null
      ? this
      : CardPalette(
          gradients: {
            for (final tone in CardTone.values)
              tone: LinearGradient.lerp(this[tone], other[tone], t)!,
          },
          ink: Color.lerp(ink, other.ink, t)!,
          inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
          chipFill: Color.lerp(chipFill, other.chipFill, t)!,
        );
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
