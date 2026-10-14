import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/exam_paper.dart';

import '../../../support/real_content.dart';

void main() {
  final content = loadRealContent();
  final byId = {for (final q in content.questions) q.id: q};
  ExamStructure structure(String id) =>
      content.structures.firstWhere((s) => s.id == id);
  const generator = ExamGenerator();

  for (final id in ['A1-2025', 'A-2025', 'B-2025']) {
    test('1.000 đề $id đều đúng cấu trúc BR-02, BR-03 (NFR-05)', () {
      final s = structure(id);
      for (var seed = 0; seed < 1000; seed++) {
        final paper = generator.generate(
          structure: s,
          bank: content.questions,
          random: Random(seed),
        );

        expect(paper.length, s.questionCount);
        expect(
          paper.questionIds.toSet(),
          hasLength(s.questionCount),
          reason: 'trùng câu (seed $seed)',
        );

        final qs = [for (final qid in paper.questionIds) byId[qid]!];
        expect(
          qs.every((q) => q.inPool(s.pool!)),
          isTrue,
          reason: 'câu ngoài bộ của hạng (seed $seed)',
        );

        final critical = qs
            .where((q) => q.isCriticalFor(s.licenseClass))
            .toList();
        expect(
          critical,
          hasLength(1),
          reason: 'phải đúng 1 câu điểm liệt của hạng (seed $seed)',
        );
        expect(critical.single.id, paper.criticalQuestionId);

        // groups appear in blueprint order with the right size
        var pos = 0;
        for (final g in s.distribution) {
          final slice = qs.sublist(pos, pos + g.count);
          if (g.critical) {
            expect(slice.single.isCriticalFor(s.licenseClass), isTrue);
          } else {
            expect(
              slice.every((q) => g.chapters.contains(q.chapter)),
              isTrue,
              reason: 'nhóm $g (seed $seed)',
            );
            expect(slice.any((q) => q.isCriticalFor(s.licenseClass)), isFalse);
          }
          pos += g.count;
        }
      }
    });
  }

  test('đề cố định: cùng hạng + số đề + phiên bản dữ liệu → cùng danh sách câu (FR-A20b)', () {
    final s = structure('B-2025');
    ExamPaper fixed(int no, String version) => generator.generateFixed(
      structure: s,
      bank: content.questions,
      setNo: no,
      contentVersion: version,
    );

    expect(
      fixed(1, content.version).questionIds,
      fixed(1, content.version).questionIds,
    );
    expect(fixed(1, content.version).fixedSetNo, 1);
    final twenty = {
      for (var no = 1; no <= 20; no++)
        fixed(no, content.version).questionIds.join(),
    };
    expect(twenty, hasLength(20), reason: '20 đề cố định phải khác nhau');
  });

  test('không xáo thứ tự đáp án: id câu giữ nguyên đáp án gốc', () {
    final s = structure('A1-2025');
    final paper = generator.generate(
      structure: s,
      bank: content.questions,
      random: Random(7),
    );
    for (final qid in paper.questionIds) {
      final q = byId[qid]!;
      expect(
        q.options,
        content.questions.firstWhere((x) => x.id == qid).options,
      );
    }
  });

  test('cấu trúc 2027 chưa đủ thông tin thì không sinh đề', () {
    final s = structure('B-2027');
    expect(
      () => generator.generate(
        structure: s,
        bank: content.questions,
        random: Random(1),
      ),
      throwsA(isA<ExamGenerationException>()),
    );
  });
}
