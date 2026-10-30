import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

/// Ambient (never-ending) motion such as [KenBurns]. Widget tests turn it off: a repeating animation never
/// lets `pumpAndSettle` finish. The system "remove animations" setting turns it off too.
final ambientMotionProvider = Provider<bool>((ref) => true);

bool _reduced(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// A photo that slowly breathes: zooms in and drifts a little, then back, forever (one cycle ≈ 28 s).
class KenBurns extends ConsumerStatefulWidget {
  const KenBurns({
    super.key,
    required this.child,
    this.drift = const Offset(-0.03, 0.02),
  });

  final Widget child;

  /// How far the photo drifts at full zoom, as a fraction of its size.
  final Offset drift;

  @override
  ConsumerState<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends ConsumerState<KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on = ref.read(ambientMotionProvider) && !_reduced(context);
    if (on && !_c.isAnimating) _c.repeat(reverse: true);
    if (!on) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // its own layer: each frame repaints only the photo, not the whole screen around it
  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRect(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOutSine.transform(_c.value);
          return FractionalTranslation(
            translation: widget.drift * t,
            child: Transform.scale(scale: 1.04 + 0.08 * t, child: child),
          );
        },
        child: widget.child,
      ),
    ),
  );
}

/// Fades and rises into place [index] × [AppMotion.stagger] after the screen appears; instant with reduced motion.
class Entrance extends StatelessWidget {
  const Entrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const base = 420;
    final delay = index * AppMotion.stagger.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, Duration(milliseconds: base + delay)),
      curve: Interval(delay / (base + delay), 1, curve: AppMotion.quickCurve),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Shrinks a little while pressed and springs back on release, like a button on iOS.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.pressed});

  final Widget child;

  /// Given by the owner when it knows better than raw pointers, e.g. an InkWell's highlight, which is only
  /// set for a tap and not when the touch turns into a scroll. Null: follow the pointer (a lone button).
  final bool? pressed;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final down = widget.pressed ?? _down;
    final scaled = AnimatedScale(
      scale: down ? 0.97 : 1,
      duration: AppMotion.of(
        context,
        down ? const Duration(milliseconds: 110) : AppMotion.spring,
      ),
      curve: down ? Curves.easeOut : AppMotion.springCurve,
      child: widget.child,
    );
    if (widget.pressed != null) return scaled;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: scaled,
    );
  }
}

/// A number that counts up to [value] when it first appears and glides when it changes.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.builder});

  final int value;
  final Widget Function(BuildContext context, int shown) builder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.toDouble()),
    duration: AppMotion.of(context, const Duration(milliseconds: 900)),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => builder(context, v.round()),
  );
}
