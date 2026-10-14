import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/features/home/domain/home_summary.dart';

void main() {
  Question q(String id, {bool critical = false}) => Question(
    id: id,
    number: int.parse(id.substring(1)),
    chapter: 1,
    content: '',
    images: const [],
    options: const ['a', 'b'],
    correctIndex: 0,
    criticalFor: critical ? const ['A1'] : const [],
    licenseClasses: const ['A1'],
  );

  final pool = [q('Q0001'), q('Q0002', critical: true), q('Q0003'), q('Q0004')];

  HomeSummary summarize({
    Set<String> correct = const {},
    Set<String> wrong = const {},
  }) => HomeSummary.compute(
    licenseClass: 'A1',
    pool: pool,
    lastCorrectIds: correct,
    wrongListIds: wrong,
    openSession: null,
  );

  test('chưa học câu nào → tiến độ 0, không chia cho 0', () {
    final s = summarize();
    expect(
      [s.poolSize, s.correctCount, s.wrongCount, s.progress],
      [4, 0, 0, 0.0],
    );
  });

  test('đếm câu điểm liệt của hạng trong bộ câu hỏi', () {
    expect(summarize().criticalCount, 1);
  });

  test('chỉ tính câu thuộc bộ câu hỏi của hạng', () {
    final s = summarize(correct: {'Q0001', 'Q0500'}, wrong: {'Q0003', 'Q0600'});
    expect([s.correctCount, s.wrongCount], [1, 1]);
    expect(s.progress, 0.25);
  });

  test('bộ câu hỏi rỗng → tiến độ 0', () {
    final s = HomeSummary.compute(
      licenseClass: 'A1',
      pool: const [],
      lastCorrectIds: const {},
      wrongListIds: const {},
      openSession: null,
    );
    expect(s.progress, 0);
  });
}
