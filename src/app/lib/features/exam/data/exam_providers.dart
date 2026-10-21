import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../domain/exam_grader.dart';
import '../domain/exam_session.dart';
import '../domain/structure_picker.dart';

/// Number of fixed test sets per class (FR-A20b).
const fixedSetCount = 20;

/// Blueprint in force today for the selected class, or null (no class / no complete blueprint).
final currentStructureProvider = FutureProvider<ExamStructure?>((ref) async {
  final licenseClass = (await ref.watch(settingsProvider.future)).licenseClass;
  if (licenseClass == null) return null;
  final content = await ref.watch(contentProvider.future);
  return StructurePicker.pick(
    content.structures,
    licenseClass,
    ref.read(clockProvider)(),
  )?.structure;
});

/// Latest result per fixed set of the selected class (exam list screen).
final fixedResultsProvider =
    FutureProvider<Map<int, ({int score, bool passed})>>((ref) async {
      final licenseClass = (await ref.watch(settingsProvider.future))
          .licenseClass;
      if (licenseClass == null) return const {};
      final repo = await ref.watch(examSessionRepositoryProvider.future);
      return repo.latestFixedResults(licenseClass);
    });

/// A stored test with everything needed to show it: questions in paper order and its blueprint.
class ExamView {
  const ExamView({
    required this.session,
    required this.questions,
    required this.structure,
  });

  final ExamSession session;
  final List<Question> questions;
  final ExamStructure structure;

  /// Grades the given answers (null = unanswered) against this paper.
  ExamResult grade(List<int?> answers) => const ExamGrader().grade(
    paper: session.paper,
    structure: structure,
    questionsById: {for (final q in questions) q.id: q},
    answers: answers,
  );
}

/// Loads a test by id from the database (answers as saved). Null if unknown.
final examViewProvider = FutureProvider.autoDispose.family<ExamView?, int>((
  ref,
  id,
) async {
  final content = await ref.watch(contentProvider.future);
  final repo = await ref.watch(examSessionRepositoryProvider.future);
  final session = await repo.byId(id);
  if (session == null) return null;
  final byId = {for (final q in content.questions) q.id: q};
  final structure = content.structures
      .where((s) => s.id == session.paper.structureId)
      .firstOrNull;
  final questions = [for (final qid in session.paper.questionIds) byId[qid]];
  if (structure == null || questions.contains(null)) {
    return null; // content version no longer has it
  }
  return ExamView(
    session: session,
    questions: questions.cast<Question>(),
    structure: structure,
  );
});
