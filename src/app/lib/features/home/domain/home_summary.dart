import '../../../core/content/models.dart';
import '../../exam/domain/exam_session.dart';

/// Numbers shown on the home screen for the selected class (ST-04). Pure Dart.
class HomeSummary {
  const HomeSummary({
    required this.licenseClass,
    required this.poolSize,
    required this.correctCount,
    required this.wrongCount,
    required this.criticalCount,
    required this.openSession,
    this.savedCount = 0,
    this.structure,
  });

  /// [pool] is the class's question pool; only progress on those questions counts.
  /// [lastCorrectIds]: questions whose latest answer was correct (FR-A10). [wrongListIds]: the "Câu sai" list.
  factory HomeSummary.compute({
    required String licenseClass,
    required List<Question> pool,
    required Set<String> lastCorrectIds,
    required Set<String> wrongListIds,
    required ExamSession? openSession,
    Set<String> savedIds = const {},
    ExamStructure? structure,
  }) {
    var correct = 0;
    var wrong = 0;
    var saved = 0;
    for (final q in pool) {
      if (lastCorrectIds.contains(q.id)) correct++;
      if (wrongListIds.contains(q.id)) wrong++;
      if (savedIds.contains(q.id)) saved++;
    }
    return HomeSummary(
      licenseClass: licenseClass,
      poolSize: pool.length,
      correctCount: correct,
      wrongCount: wrong,
      criticalCount: pool.where((q) => q.isCriticalFor(licenseClass)).length,
      openSession: openSession,
      savedCount: saved,
      structure: structure,
    );
  }

  final String licenseClass;
  final int poolSize;

  /// Questions whose latest answer was correct.
  final int correctCount;

  /// Questions in the "Câu sai" list.
  final int wrongCount;
  final int criticalCount;

  /// Unfinished test, if any (AC3).
  final ExamSession? openSession;

  /// Bookmarked questions in this class's pool ("Câu đã lưu").
  final int savedCount;

  /// Test blueprint in force today, for the "Thi thử" button; null if the class has none.
  final ExamStructure? structure;

  double get progress => poolSize == 0 ? 0 : correctCount / poolSize;
}
