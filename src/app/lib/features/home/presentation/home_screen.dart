import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';

/// Temporary home screen; the real one (feature tiles, progress) comes in ST-04.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final licenseClass = ref.watch(settingsProvider).value?.licenseClass;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appName),
        actions: [
          IconButton(
            tooltip: S.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(Routes.about),
          ),
        ],
      ),
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
              if (licenseClass != null)
                Text(S.currentClass(licenseClass), style: text.titleLarge),
              const SizedBox(height: 8),
              Text(
                S.contentLoaded(c.questions.length, c.signs.length),
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(S.contentVersion(c.version), style: text.bodySmall),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.push(Routes.licenseClass),
                child: const Text(S.changeClass),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
