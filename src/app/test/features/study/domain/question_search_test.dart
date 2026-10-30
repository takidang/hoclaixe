import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/signs/domain/sign_search.dart';
import 'package:hoclaixe/features/study/domain/question_search.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';

import '../../../support/real_content.dart';

void main() {
  final content = loadRealContent();
  final b = StructurePicker.pick(
    content.structures,
    'B',
    DateTime(2026, 10, 30),
  )!.structure;
  final pool = questionPool(content.questions, 'B', pool: b.pool);

  group('searchQuestions', () {
    test('gõ số → câu có số gốc đó đứng đầu', () {
      final target = pool[119];
      final found = searchQuestions(pool, '${target.number}');
      expect(found.first, same(target));
    });

    test('gõ không dấu "nong do con" → chỉ ra các câu có "nồng độ cồn", theo thứ tự gốc', () {
      final found = searchQuestions(pool, 'nong do con');
      expect(found, isNotEmpty);
      for (final q in found) {
        expect(
          foldForSearch(q.content).contains('nong do con') ||
              q.options.any((o) => foldForSearch(o).contains('nong do con')),
          isTrue,
          reason: 'câu ${q.number}',
        );
      }
      final numbers = [for (final q in found) q.number];
      expect(numbers, [...numbers]..sort());
      expect(
        searchQuestions(pool, 'NỒNG ĐỘ CỒN'),
        found,
        reason: 'có dấu, chữ hoa cũng như nhau',
      );
    });

    test('chuỗi rỗng hoặc không khớp → không có kết quả', () {
      expect(searchQuestions(pool, '   '), isEmpty);
      expect(searchQuestions(pool, 'zzzzqqq'), isEmpty);
    });
  });

  group('chủ đề "Câu đã lưu" và một câu', () {
    test('Câu đã lưu: theo thứ tự lưu, bỏ câu ngoài bộ câu của hạng', () {
      final topic = resolveTopic(
        StudyTopic.savedId,
        pool: pool,
        licenseClass: 'B',
        wrongIds: const {},
        savedIds: [pool[5].id, 'không-có', pool[2].id],
      )!;
      expect(topic.kind, TopicKind.saved);
      expect(topic.questions, [pool[5], pool[2]]);
      expect(topic.isSnapshot, isTrue);
    });

    test('một câu (mở từ tìm kiếm): đúng câu đó; mã lạ → null', () {
      final topic = resolveTopic(
        StudyTopic.single(pool[7].id),
        pool: pool,
        licenseClass: 'B',
        wrongIds: const {},
      )!;
      expect(topic.questions, [pool[7]]);
      expect(topic.isSnapshot, isTrue);
      expect(
        resolveTopic(
          StudyTopic.single('không-có'),
          pool: pool,
          licenseClass: 'B',
          wrongIds: const {},
        ),
        isNull,
      );
    });
  });
}
