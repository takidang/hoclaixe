import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/image_zoom_page.dart';
import 'sign_image.dart';

/// One sign (ST-12 AC2): large picture(s), code, name, group, short description; full QCVN text on demand.
class SignDetailScreen extends ConsumerWidget {
  const SignDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider).value;
    final sign = content?.signs.where((s) => s.code == code).firstOrNull;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (sign == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text(S.signNotFound)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(sign.code)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (sign.images.isEmpty) ...[
                    SignImage(sign: sign, size: 160),
                    if (sign.noImageReason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        sign.noImageReason!,
                        style: text.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                  for (final asset in sign.images)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Semantics(
                        button: true,
                        label: S.zoomImage,
                        child: GestureDetector(
                          onTap: () => ImageZoomPage.open(context, asset),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SignImage(
                              sign: sign,
                              size: 220,
                              asset: asset,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sign.code,
            style: text.titleMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            sign.name,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(sign.groupName),
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (sign.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(sign.summary, style: text.bodyLarge),
          ],
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: const Text(S.signMeaningFull),
              shape: const Border(),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [Text(sign.meaning, style: text.bodyMedium)],
            ),
          ),
        ],
      ),
    );
  }
}
