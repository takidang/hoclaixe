import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// State of one segment in [LaneLine.segments].
enum LaneMark { done, wrong, empty }

/// The signature element of design v1 (docs/design/DESIGN.md): a lane marking that is dashed where the
/// learner has not got yet and painted solid where they have, like marking 3.3 turning into 3.2.
///
/// [LaneLine.progress] paints the first [value] of the width solid; a new value is painted on from the old
/// one ([AppMotion.paint]). [LaneLine.segments] draws one segment per question (test result).
class LaneLine extends StatelessWidget {
  const LaneLine.progress({
    super.key,
    required double this.value,
    required this.color,
    this.thickness = 4,
    this.semanticsLabel,
  }) : marks = null,
       wrongColor = null;

  const LaneLine.segments({
    super.key,
    required List<LaneMark> this.marks,
    required this.color,
    required Color this.wrongColor,
    this.thickness = 6,
    this.semanticsLabel,
  }) : value = null;

  final double? value;
  final List<LaneMark>? marks;
  final Color color;
  final Color? wrongColor;
  final double thickness;

  /// Read by screen readers instead of the drawing (the numbers are always shown as text too).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final marks = this.marks;
    final Widget line = marks != null
        ? CustomPaint(
            painter: _SegmentsPainter(marks, color, wrongColor!),
            size: Size.fromHeight(thickness),
          )
        : TweenAnimationBuilder<double>(
            tween: Tween(end: value!.clamp(0, 1)),
            duration: AppMotion.of(context, AppMotion.paint),
            curve: AppMotion.paintCurve,
            builder: (context, v, _) => CustomPaint(
              painter: _ProgressPainter(v, color),
              size: Size.fromHeight(thickness),
            ),
          );
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox(height: thickness, width: double.infinity, child: line),
    );
  }
}

/// Dash and gap of the unpainted part, 1:1 like marking 3.3.
const _dash = 12.0;

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final r = Radius.circular(h / 2);
    final painted = size.width * value;
    final dashPaint = Paint()..color = color.withValues(alpha: 0.45);
    // dashes stay on a fixed grid so the solid part covers them as it grows; the dash is stretched
    // slightly so whole dashes fill the width, with no clipped stub at the right end
    final n = math.max(1, ((size.width + _dash) / (_dash * 2)).round());
    final dash = size.width / (n * 2 - 1);
    for (var i = 0; i < n; i++) {
      final x = i * dash * 2;
      final end = x + dash;
      if (end <= painted) continue;
      final start = x < painted ? painted : x;
      canvas.drawRRect(RRect.fromLTRBR(start, 0, end, h, r), dashPaint);
    }
    if (painted > 0) {
      canvas.drawRRect(
        RRect.fromLTRBR(0, 0, painted, h, r),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.value != value || old.color != color;
}

class _SegmentsPainter extends CustomPainter {
  _SegmentsPainter(this.marks, this.color, this.wrongColor);

  final List<LaneMark> marks;
  final Color color;
  final Color wrongColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (marks.isEmpty) return;
    const gap = 3.0;
    final h = size.height;
    final w = (size.width - gap * (marks.length - 1)) / marks.length;
    final r = Radius.circular(h / 2);
    for (var i = 0; i < marks.length; i++) {
      final x = i * (w + gap);
      final paint = Paint()
        ..color = switch (marks[i]) {
          LaneMark.done => color,
          LaneMark.wrong => wrongColor,
          LaneMark.empty => color.withValues(alpha: 0.2),
        };
      canvas.drawRRect(RRect.fromLTRBR(x, 0, x + w, h, r), paint);
    }
  }

  @override
  bool shouldRepaint(_SegmentsPainter old) =>
      old.marks != marks || old.color != color || old.wrongColor != wrongColor;
}
