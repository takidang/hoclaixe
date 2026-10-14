import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/exam_grader.dart';

import '../../../support/real_content.dart';

/// Mandatory grading table (NFR-05b) for A1 (pass 21/25), A (23/25), B (27/30).
void main() {
  final content = loadRealContent();
  final byId = {for (final q in content.questions) q.id: q};
  const grader = ExamGrader();

  for (final id in ['A1-2025', 'A-2025', 'B-2025']) {
    group(id, () {
      final s = content.structures.firstWhere((x) => x.id == id);
      final paper = const ExamGenerator().generate(
        structure: s,
        bank: content.questions,
        random: Random(42),
      );
      final criticalPos = paper.questionIds.indexOf(paper.criticalQuestionId);
      final right = [
        for (final qid in paper.questionIds) byId[qid]!.correctIndex,
      ];
      int wrongOf(int pos) =>
          (right[pos] + 1) % byId[paper.questionIds[pos]]!.options.length;

      ExamResult grade(List<int?> answers) => grader.grade(
        paper: paper,
        structure: s,
        questionsById: byId,
        answers: answers,
      );

      /// [correct] answers right in total (critical included when [criticalRight]); the rest wrong.
      List<int?> answers({
        required int correct,
        required bool criticalRight,
        bool criticalBlank = false,
      }) {
        var left = correct - (criticalRight ? 1 : 0);
        return [
          for (var i = 0; i < paper.length; i++)
            if (i == criticalPos)
              criticalBlank ? null : (criticalRight ? right[i] : wrongOf(i))
            else if (left-- > 0)
              right[i]
            else
              wrongOf(i),
        ];
      }

      test('đúng toàn bộ → Đạt', () {
        final r = grade(right);
        expect(
          [r.passed, r.score, r.total],
          [true, s.questionCount, s.questionCount],
        );
      });

      test('đúng bằng ngưỡng ${s.passScore} và đúng câu điểm liệt → Đạt', () {
        final r = grade(answers(correct: s.passScore, criticalRight: true));
        expect(r.score, s.passScore);
        expect(r.passed, isTrue);
      });

      test('thiếu 1 điểm dù đúng câu điểm liệt → Không đạt (thiếu điểm)', () {
        final r = grade(answers(correct: s.passScore - 1, criticalRight: true));
        expect(r.passed, isFalse);
        expect(r.failReasons, {FailReason.notEnoughScore});
      });

      test('trượt khi sai câu điểm liệt dù đủ điểm', () {
        final r = grade(
          answers(correct: s.questionCount - 1, criticalRight: false),
        );
        expect(r.score, greaterThanOrEqualTo(s.passScore));
        expect(r.passed, isFalse);
        expect(r.failReasons, {FailReason.wrongCritical});
      });

      test('trượt khi bỏ trống câu điểm liệt dù đủ điểm (GA2)', () {
        final r = grade(
          answers(
            correct: s.questionCount - 1,
            criticalRight: false,
            criticalBlank: true,
          ),
        );
        expect(r.unanswered, 1);
        expect(r.failReasons, {FailReason.wrongCritical});
      });

      test(
        'bỏ trống toàn bộ → Không đạt cả hai lý do, câu bỏ trống tính là sai',
        () {
          final r = grade(List.filled(paper.length, null));
          expect([r.score, r.unanswered], [0, s.questionCount]);
          expect(r.failReasons, {
            FailReason.notEnoughScore,
            FailReason.wrongCritical,
          });
        },
      );
    });
  }

  test('số đáp án không khớp số câu → lỗi', () {
    final s = content.structures.firstWhere((x) => x.id == 'B-2025');
    final paper = const ExamGenerator().generate(
      structure: s,
      bank: content.questions,
      random: Random(1),
    );
    expect(
      () => grader.grade(
        paper: paper,
        structure: s,
        questionsById: byId,
        answers: [0],
      ),
      throwsArgumentError,
    );
  });
}
