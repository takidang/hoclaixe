import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

/// A pastel gradient card (design v2). Text and icons inside default to [AppTheme.ink].
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.gradient,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });

  final Gradient gradient;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: AppTheme.ink),
              child: IconTheme.merge(
                data: const IconThemeData(color: AppTheme.ink),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A real road sign from the catalog on a white disc: the illustration of a gradient card.
/// Decorative (hidden from screen readers); nothing is drawn if the code is not in the catalog.
class SignBadge extends ConsumerWidget {
  const SignBadge({super.key, required this.code, this.size = 64});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signs = ref.watch(contentProvider).value?.signs ?? const [];
    final asset = signs
        .where((s) => s.code == code && s.images.isNotEmpty)
        .firstOrNull
        ?.images
        .first;
    if (asset == null) return SizedBox.square(dimension: size);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

/// Translucent white pill on a gradient card, e.g. "250 câu".
class CountChip extends StatelessWidget {
  const CountChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.ink),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: AppTheme.ink),
          ),
        ],
      ),
    ),
  );
}
