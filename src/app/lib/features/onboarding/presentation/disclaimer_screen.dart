import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';
import '../../about/presentation/sources_section.dart';

/// First launch (FR-A01). The router moves on as soon as the choice is saved.
class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(S.disclaimerTitle, style: text.headlineSmall),
                  const SizedBox(height: 16),
                  Text(S.disclaimerBody, style: text.bodyLarge),
                  const SizedBox(height: 24),
                  const SourcesSection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).acceptDisclaimer(),
                  child: const Text(S.disclaimerAccept),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
