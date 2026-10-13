import '../../../core/content/models.dart';
import 'exam_paper.dart';

enum FailReason {
  /// Score below the pass mark.
  notEnoughScore,

  /// The critical question was answered wrongly or left unanswered (BR-05, GA2).
  wrongCritical,
}

class ExamResult {
  const ExamResult({
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.passScore,
    required this.criticalCorrect,
    required this.correctByPosition,
  });

  final int total;
  final int correct;
  final int wrong;
  final int unanswered;
  final int passScore;
  final bool criticalCorrect;

  /// For each position: true = correct, false = wrong, null = unanswered.
  final List<bool?> correctByPosition;

  /// Score = number of correct answers, critical question included (BR-04, GA3).
  int get score => correct;

  Set<FailReason> get failReasons => {
    if (score < passScore) FailReason.notEnoughScore,
    if (!criticalCorrect) FailReason.wrongCritical,
  };

  /// Pass only with enough points AND the critical question right (BR-05).
  bool get passed => failReasons.isEmpty;
}

class ExamGrader {
  const ExamGrader();

  /// [answers] holds the chosen option index per position (null = unanswered = wrong, BR-04).
  ExamResult grade({
    required ExamPaper paper,
    required ExamStructure structure,
    required Map<String, Question> questionsById,
    required List<int?> answers,
  }) {
    if (answers.length != paper.length) {
      throw ArgumentError(
        'Cần ${paper.length} đáp án, nhận ${answers.length}.',
      );
    }
    final byPosition = <bool?>[];
    var criticalCorrect = false;
    for (var i = 0; i < paper.length; i++) {
      final id = paper.questionIds[i];
      final question = questionsById[id];
      if (question == null) {
        throw StateError('Không tìm thấy câu $id trong bộ câu hỏi.');
      }
      final chosen = answers[i];
      final ok = chosen == null ? null : chosen == question.correctIndex;
      byPosition.add(ok);
      if (id == paper.criticalQuestionId) criticalCorrect = ok ?? false;
    }
    return ExamResult(
      total: paper.length,
      correct: byPosition.where((r) => r == true).length,
      wrong: byPosition.where((r) => r == false).length,
      unanswered: byPosition.where((r) => r == null).length,
      passScore: structure.passScore,
      criticalCorrect: criticalCorrect,
      correctByPosition: List.unmodifiable(byPosition),
    );
  }
}
