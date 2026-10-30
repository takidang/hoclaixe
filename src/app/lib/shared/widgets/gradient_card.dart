import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import 'motion.dart';

/// A gradient card (design v2): colours from [CardPalette] for the current light / dark mode.
/// Text and icons inside default to [CardPalette.ink].
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.tone,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });

  final CardTone tone;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    final palette = CardPalette.of(context);
    final card = Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          gradient: palette[tone],
          borderRadius: radius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          // feedback is the press scale below, not a Material ripple (design: iOS-like)
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: palette.ink),
              child: IconTheme.merge(
                data: IconThemeData(color: palette.ink),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    return onTap == null ? card : PressScale(child: card);
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
        decoration: const BoxDecoration(
          color: AppTheme.badgeFill,
          shape: BoxShape.circle,
        ),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

/// Translucent pill on a gradient card, e.g. "250 câu".
class CountChip extends StatelessWidget {
  const CountChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = CardPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.chipFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: palette.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: palette.ink),
            ),
          ],
        ),
      ),
    );
  }
}
