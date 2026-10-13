/// A generated test: the question ids in display order. Stored as a snapshot in `exam_session` (BR-09).
class ExamPaper {
  const ExamPaper({
    required this.licenseClass,
    required this.structureId,
    required this.questionIds,
    required this.criticalQuestionId,
    this.fixedSetNo,
  });

  final String licenseClass;
  final String structureId;
  final List<String> questionIds;

  /// The one critical question of this test (wrong or unanswered → fail, BR-05).
  final String criticalQuestionId;

  /// 1…20 for the fixed sets (FR-A20b), null for a random test.
  final int? fixedSetNo;

  int get length => questionIds.length;
}
