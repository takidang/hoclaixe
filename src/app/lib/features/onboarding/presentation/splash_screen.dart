import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';

/// Shown while settings load; shows the error if the local database cannot be opened.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: settings.hasError
              ? const Text(S.settingsError, textAlign: TextAlign.center)
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
