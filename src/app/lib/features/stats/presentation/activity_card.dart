import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/daily_activity.dart';

/// "Số câu đã làm": one stacked bar per day for 30 days (pink = study, blue = practice tests), totals and
/// the study streak. Counts answers, not time: the app does not measure time spent.
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.days});

  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final study = days.fold(0, (n, d) => n + d.study);
    final exam = days.fold(0, (n, d) => n + d.exam);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(S.activityTitle, style: text.titleLarge),
                Text(
                  S.last30Days,
                  style: text.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (study + exam == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  S.noActivity,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              Semantics(
                label: S.activitySummary(study, exam),
                excludeSemantics: true,
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _BarsPainter(
                      days,
                      study: scheme.secondary,
                      exam: scheme.primary,
                      empty: scheme.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  _Legend(color: scheme.secondary, label: S.legendStudy),
                  _Legend(color: scheme.primary, label: S.legendExam),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _Total(value: study + exam, label: S.totalAnswers),
                _Total(value: study, label: S.legendStudy),
                _Total(value: exam, label: S.legendExam),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(child: Text(S.streak, style: text.titleSmall)),
                Text(
                  S.days(studyStreak(days)),
                  style: text.titleSmall?.copyWith(color: scheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: const SizedBox.square(dimension: 12),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _Total extends StatelessWidget {
  const _Total({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: AppTheme.mono(text.titleLarge)),
          Text(
            label,
            style: text.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stacked bars: practice tests at the bottom, study on top, a short grey stub for an empty day.
class _BarsPainter extends CustomPainter {
  _BarsPainter(
    this.days, {
    required this.study,
    required this.exam,
    required this.empty,
  });

  final List<DayActivity> days;
  final Color study;
  final Color exam;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final slot = size.width / days.length;
    final bar = math.min(8.0, slot * 0.6);
    final r = Radius.circular(bar / 2);
    final top = days.map((d) => d.total).reduce(math.max);
    const gap = 2.0;
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      final x = i * slot + (slot - bar) / 2;
      if (d.total == 0) {
        canvas.drawRRect(
          RRect.fromLTRBR(x, size.height - bar, x + bar, size.height, r),
          Paint()..color = empty,
        );
        continue;
      }
      final scale = size.height / top;
      var y = size.height;
      for (final (n, color) in [(d.exam, exam), (d.study, study)]) {
        if (n == 0) continue;
        final h = math.max(bar, n * scale - gap);
        canvas.drawRRect(
          RRect.fromLTRBR(x, math.max(0, y - h), x + bar, y, r),
          Paint()..color = color,
        );
        y -= h + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.days != days ||
      old.study != study ||
      old.exam != exam ||
      old.empty != empty;
}
