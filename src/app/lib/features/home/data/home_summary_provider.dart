import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../exam/domain/question_pool.dart';
import '../../exam/domain/structure_picker.dart';
import '../domain/home_summary.dart';

/// Home screen numbers for the selected class. Screens that record answers or change
/// sessions call `ref.invalidate(homeSummaryProvider)` so the home screen is up to date.
final homeSummaryProvider = FutureProvider<HomeSummary?>((ref) async {
  final licenseClass = (await ref.watch(settingsProvider.future)).licenseClass;
  if (licenseClass == null) return null;
  final content = await ref.watch(contentProvider.future);
  final progressRepo = await ref.watch(progressRepositoryProvider.future);
  final sessionRepo = await ref.watch(examSessionRepositoryProvider.future);
  final structure = StructurePicker.pick(
    content.structures,
    licenseClass,
    ref.read(clockProvider)(),
  )?.structure;
  final progress = await progressRepo.allProgress();
  return HomeSummary.compute(
    licenseClass: licenseClass,
    pool: questionPool(content.questions, licenseClass, pool: structure?.pool),
    lastCorrectIds: {
      for (final p in progress.values)
        if (p.lastCorrect) p.questionId,
    },
    wrongListIds: {
      for (final p in progress.values)
        if (p.inWrongList) p.questionId,
    },
    openSession: await sessionRepo.openSession(),
    savedIds: (await progressRepo.savedIds()).toSet(),
    structure: structure,
  );
});
