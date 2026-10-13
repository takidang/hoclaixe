import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/strings.dart';

/// Temporary home screen: proves content loads. Replaced by the real home in Sprint 1 (15–18/10).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.appName)),
      body: Center(
        child: content.when(
          loading: () => const Text(S.loading),
          error: (e, _) => const Padding(
            padding: EdgeInsets.all(24),
            child: Text(S.contentError, textAlign: TextAlign.center),
          ),
          data: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.contentLoaded(c.questions.length, c.signs.length),
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(S.contentVersion(c.version), style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
