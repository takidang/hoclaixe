import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';

import '../../../support/real_content.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 14);

  List<StudyTopic> topicsFor(String cls) {
    final s = StructurePicker.pick(content.structures, cls, now)!.structure;
    return buildTopics(
      pool: questionPool(content.questions, cls, pool: s.pool),
      licenseClass: cls,
    );
  }

  for (final cls in ['A1', 'A', 'B']) {
    test(
      'hạng $cls: Tất cả, Điểm liệt rồi các chương có câu trong bộ câu, không chương rỗng (FR-A10)',
      () {
        final topics = topicsFor(cls);
        expect(topics.take(2).map((t) => t.id), [
          StudyTopic.allId,
          StudyTopic.criticalId,
        ]);
        final chapters = topics.skip(2).toList();
        expect(chapters.every((t) => t.questions.isNotEmpty), isTrue);
        expect(
          chapters.fold(0, (n, t) => n + t.questions.length),
          topics.first.questions.length,
          reason: 'mỗi câu thuộc đúng một chương',
        );
        expect(topics[1].questions.every((q) => q.isCriticalFor(cls)), isTrue);
      },
    );
  }

  test(
    'số câu theo CV 2262: A1 250 câu / 20 điểm liệt, B 600 câu / 60 điểm liệt',
    () {
      expect(
        [
          topicsFor('A1')[0].questions.length,
          topicsFor('A1')[1].questions.length,
        ],
        [250, 20],
      );
      expect(
        [
          topicsFor('B')[0].questions.length,
          topicsFor('B')[1].questions.length,
        ],
        [600, 60],
      );
    },
  );

  group('resolveTopic', () {
    final pool = questionPool(content.questions, 'B');
    StudyTopic? resolve(String id, [Set<String> wrong = const {}]) =>
        resolveTopic(id, pool: pool, licenseClass: 'B', wrongIds: wrong);

    test('tìm theo id; id lạ → null', () {
      expect(resolve('ch5')!.questions.every((q) => q.chapter == 5), isTrue);
      expect(resolve('ch9'), isNull);
      expect(resolve('xyz'), isNull);
      expect(resolve('wrong-wrong-ch1'), isNull);
    });

    test('câu sai của chủ đề = câu trong chủ đề và trong danh sách câu sai, giữ thứ tự gốc', () {
      final ch1 = resolve('ch1')!;
      final wrong = {
        ch1.questions[7].id,
        ch1.questions[2].id,
        'Q0590',
      }; // Q0590 thuộc chương VI
      final t = resolve(StudyTopic.wrongOf('ch1'), wrong)!;
      expect(t.isWrongList, isTrue);
      expect(t.baseId, 'ch1');
      expect(t.questionIds, [ch1.questions[2].id, ch1.questions[7].id]);
    });
  });

  test('Đúng / Sai / Chưa làm theo kết quả gần nhất', () {
    final topic = topicsFor('A1')[1];
    final ids = topic.questionIds;
    final stats = TopicStats.of(topic, {
      ids[0]: true,
      ids[1]: false,
      ids[2]: true,
      'Q9999': true,
    });
    expect(
      [stats.correct, stats.wrong, stats.notDone, stats.total],
      [2, 1, ids.length - 3, ids.length],
    );
  });

  test('tóm tắt lượt: chỉ xong khi mọi câu đã trả lời', () {
    final topic = topicsFor('A1')[1];
    final answers = {for (final q in topic.questions) q.id: q.correctIndex};
    answers[topic.questions.first.id] = topic.questions.first.correctIndex == 0
        ? 1
        : 0;
    final done = RoundSummary.of(topic, answers);
    expect(
      [done.correct, done.wrong, done.finished],
      [topic.questions.length - 1, 1, true],
    );
    answers.remove(topic.questions.last.id);
    expect(RoundSummary.of(topic, answers).finished, isFalse);
  });
}
