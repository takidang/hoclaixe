import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';
import 'sources_section.dart';

/// "Giới thiệu" (FR-A02): disclaimer, sources, data and app version, local-only progress (ADR-006).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(contentProvider).value?.version;
    final themeMode =
        ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.system;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.about)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(S.appearance, style: text.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(S.themeSystem),
              ),
              ButtonSegment(value: ThemeMode.light, label: Text(S.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(S.themeDark)),
            ],
            selected: {themeMode},
            showSelectedIcon: false, // text only: icons pushed "Theo máy" onto two lines on a 360 dp phone
            onSelectionChanged: (s) =>
                ref.read(settingsProvider.notifier).setThemeMode(s.single),
          ),
          const SizedBox(height: 24),
          Text(S.disclaimerBody, style: text.bodyLarge),
          const SizedBox(height: 24),
          const SourcesSection(),
          const SizedBox(height: 24),
          Text(S.progressLocalOnly, style: text.bodyMedium),
          const SizedBox(height: 16),
          if (version != null)
            Text(S.contentVersion(version), style: text.bodySmall),
          Text('${S.appName} ${S.appVersion}', style: text.bodySmall),
        ],
      ),
    );
  }
}
