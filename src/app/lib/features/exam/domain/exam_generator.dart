import 'dart:math';

import '../../../core/content/models.dart';
import 'exam_paper.dart';
import 'seeded_random.dart';

class ExamGenerationException implements Exception {
  const ExamGenerationException(this.message);

  final String message;

  @override
  String toString() => 'ExamGenerationException: $message';
}

/// Builds a test from a blueprint (BR-02, BR-03, GA6). Pure Dart; [Random] is injected so tests are repeatable.
class ExamGenerator {
  const ExamGenerator();

  /// One critical question of the licence class + N regular questions per chapter group, no duplicates.
  /// Order: groups in blueprint order, shuffled inside each group. Answer options are never shuffled.
  ExamPaper generate({
    required ExamStructure structure,
    required List<Question> bank,
    required Random random,
    int? fixedSetNo,
  }) {
    if (!structure.complete || structure.distribution.isEmpty) {
      throw ExamGenerationException(
        'Cấu trúc đề ${structure.id} chưa đủ thông tin để sinh đề.',
      );
    }
    final licenseClass = structure.licenseClass;
    final pool =
        bank.where((q) => q.inPool(structure.pool ?? licenseClass)).toList()
          ..sort(
            (a, b) => a.number.compareTo(b.number),
          ); // independent of input order
    final critical = pool.where((q) => q.isCriticalFor(licenseClass)).toList();
    final regular = pool.where((q) => !q.isCriticalFor(licenseClass)).toList();

    final used = <String>{};
    final ids = <String>[];
    String? criticalId;
    for (final group in structure.distribution) {
      final candidates =
          (group.critical
                  ? critical
                  : regular.where((q) => group.chapters.contains(q.chapter)))
              .where((q) => !used.contains(q.id))
              .toList();
      if (candidates.length < group.count) {
        throw ExamGenerationException(
          '${structure.id}: nhóm ${group.critical ? 'điểm liệt' : 'chương ${group.chapters}'} '
          'cần ${group.count} câu, chỉ có ${candidates.length}.',
        );
      }
      candidates.shuffle(random);
      final picked = candidates.take(group.count).map((q) => q.id).toList();
      if (group.critical) criticalId = picked.first;
      used.addAll(picked);
      ids.addAll(picked);
    }

    if (criticalId == null) {
      throw ExamGenerationException(
        '${structure.id}: cấu trúc đề không có câu điểm liệt.',
      );
    }
    if (ids.length != structure.questionCount) {
      throw ExamGenerationException(
        '${structure.id}: sinh ${ids.length} câu, cần ${structure.questionCount}.',
      );
    }
    return ExamPaper(
      licenseClass: licenseClass,
      structureId: structure.id,
      questionIds: List.unmodifiable(ids),
      criticalQuestionId: criticalId,
      fixedSetNo: fixedSetNo,
    );
  }

  /// Fixed set [setNo] (FR-A20b): same questions every time for the same licence class and data version.
  ExamPaper generateFixed({
    required ExamStructure structure,
    required List<Question> bank,
    required int setNo,
    required String contentVersion,
  }) => generate(
    structure: structure,
    bank: bank,
    random: SeededRandom(
      fixedSetSeed(structure.licenseClass, setNo, contentVersion),
    ),
    fixedSetNo: setNo,
  );
}

int fixedSetSeed(String licenseClass, int setNo, String contentVersion) =>
    stableHash('$licenseClass|$setNo|$contentVersion');
