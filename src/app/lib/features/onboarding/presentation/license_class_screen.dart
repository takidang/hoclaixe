import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/strings.dart';
import '../../exam/domain/structure_picker.dart';
import '../../home/data/home_summary_provider.dart';

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
                  onTap: () => _choose(context, ref, cls),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Saves the class; an unfinished test of another class is abandoned only after confirmation (ST-04 AC2).
Future<void> _choose(BuildContext context, WidgetRef ref, String cls) async {
  final sessions = await ref.read(examSessionRepositoryProvider.future);
  final open = await sessions.openSession();
  if (open != null && open.paper.licenseClass != cls) {
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.abandonExamTitle),
        content: Text(S.abandonExamBody(open.paper.licenseClass)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(S.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text(S.abandonExam)),
        ],
      ),
    );
    if (confirmed != true) return; // keep the old class and the unfinished test
    await sessions.abandon(open.id);
  }
  await ref.read(settingsProvider.notifier).chooseLicenseClass(cls);
  ref.invalidate(homeSummaryProvider);
  if (context.mounted) context.go(Routes.home);
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
