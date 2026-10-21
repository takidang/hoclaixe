import 'package:flutter/material.dart';

import '../../../core/content/models.dart';
import '../../../core/strings.dart';

/// First picture of a sign, or a neutral frame when there is none or it fails to load (ST-12 AC3).
class SignImage extends StatelessWidget {
  const SignImage({
    super.key,
    required this.sign,
    required this.size,
    this.asset,
  });

  final TrafficSign sign;
  final double size;

  /// A specific picture of the sign; defaults to the first one.
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final path = asset ?? (sign.images.isEmpty ? null : sign.images.first);
    return SizedBox.square(
      dimension: size,
      child: path == null
          ? _Placeholder(size: size)
          : Image.asset(
              path,
              fit: BoxFit.contain,
              semanticLabel: '${sign.code} ${sign.name}',
              errorBuilder: (_, _, _) => _Placeholder(size: size),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: size * 0.35,
              color: scheme.onSurfaceVariant,
            ),
            if (size >= 96)
              Text(
                S.noSignImage,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
