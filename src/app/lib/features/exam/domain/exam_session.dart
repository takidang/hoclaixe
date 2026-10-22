import 'exam_paper.dart';

enum ExamStatus { inProgress, submitted, abandoned }

/// A test being taken or already submitted (`exam_session` + `exam_answer`). Pure Dart.
class ExamSession {
  const ExamSession({
    required this.id,
    required this.paper,
    required this.startedAt,
    required this.deadlineAt,
    required this.status,
    required this.answers,
    required this.flagged,
    this.stored,
  });

  final int id;
  final ExamPaper paper;
  final DateTime startedAt;

  /// Absolute deadline (BR-06): time keeps running while the app is in the background or closed.
  final DateTime deadlineAt;
  final ExamStatus status;

  /// Chosen option per position, null = unanswered.
  final List<int?> answers;
  final List<bool> flagged;

  /// Score and outcome written when the test was submitted (null before). Result, history and the fixed-set
  /// grid all show these, so a later change of the question data cannot make them disagree.
  final ({int score, bool passed, bool failedCritical})? stored;

  bool isExpired(DateTime now) => !now.isBefore(deadlineAt);

  Duration remaining(DateTime now) =>
      isExpired(now) ? Duration.zero : deadlineAt.difference(now);

  int get answeredCount => answers.where((a) => a != null).length;
}
