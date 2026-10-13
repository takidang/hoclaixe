import 'package:flutter/material.dart';

/// Placeholder Material 3 theme — replaced by the design system made in Claude Design.
/// Widgets must read colors and text styles from Theme.of(context), never hard-code them.
abstract final class AppTheme {
  static const _seed = Color(0xFF0B5CAD);

  static ThemeData light() =>
      ThemeData(colorSchemeSeed: _seed, brightness: Brightness.light);
  static ThemeData dark() =>
      ThemeData(colorSchemeSeed: _seed, brightness: Brightness.dark);
}
