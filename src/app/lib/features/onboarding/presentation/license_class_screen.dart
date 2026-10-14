import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';
import '../../exam/domain/structure_picker.dart';

/// Choose A1, A or B (FR-A03); also used to change class from the home screen (FR-A04).
class LicenseClassScreen extends ConsumerWidget {
  const LicenseClassScreen({super.key});

  static const _groups = {
    S.motorbikeGroup: ['A1', 'A'],
    S.carGroup: ['B'],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final current = ref.watch(settingsProvider).value?.licenseClass;
    final now = ref.watch(clockProvider)();
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(S.chooseClassTitle)),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text(S.contentError)),
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final group in _groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(group.key, style: text.titleMedium),
              ),
              for (final cls in group.value)
                _ClassTile(
                  licenseClass: cls,
                  structure: StructurePicker.pick(
                    c.structures,
                    cls,
                    now,
                  )?.structure,
                  selected: cls == current,
                  onTap: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .chooseLicenseClass(cls);
                    if (context.mounted) context.go(Routes.home);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.licenseClass,
    required this.structure,
    required this.selected,
    required this.onTap,
  });

  final String licenseClass;
  final ExamStructure? structure;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = structure;
    final vehicles = S.classVehicles[licenseClass];
    return Card(
      child: ListTile(
        selected: selected,
        title: Text(S.className(licenseClass)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicles != null) Text(vehicles),
            if (s != null) ...[
              const SizedBox(height: 4),
              Text(
                S.classFacts(s.questionCount, s.durationMinutes, s.passScore),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: Icon(selected ? Icons.check_circle : Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
