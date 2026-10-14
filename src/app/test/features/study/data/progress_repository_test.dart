import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late AppDatabase app;
  late ProgressRepository repo;
  var now = DateTime(2026, 10, 14, 9);

  setUp(() async {
    app = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repo = ProgressRepository(app.db, clock: () => now);
  });
  tearDown(() => app.close());

  Future<void> answer(String id, {required bool correct}) => repo.recordAnswer(
    questionId: id,
    mode: AnswerMode.study,
    selectedIndex: correct ? 0 : 1,
    isCorrect: correct,
  );

  test('trả lời sai → vào "Câu sai", tăng số lần sai (FR-A40)', () async {
    await answer('Q0001', correct: false);
    final p = (await repo.allProgress())['Q0001']!;
    expect(
      [p.inWrongList, p.wrongCount, p.lastCorrect, p.consecutiveCorrect],
      [true, 1, false, 0],
    );
    expect(await repo.wrongList(), {'Q0001'});
  });

  test(
    'đúng 1 lần chưa ra khỏi "Câu sai", đúng 2 lần liên tiếp mới ra (GA4)',
    () async {
      await answer('Q0002', correct: false);
      await answer('Q0002', correct: true);
      expect(await repo.wrongList(), {'Q0002'});
      await answer('Q0002', correct: true);
      expect(await repo.wrongList(), isEmpty);
    },
  );

  test('sai xen giữa thì đếm lại từ đầu', () async {
    await answer('Q0003', correct: false);
    await answer('Q0003', correct: true);
    await answer('Q0003', correct: false);
    await answer('Q0003', correct: true);
    final p = (await repo.allProgress())['Q0003']!;
    expect([p.inWrongList, p.consecutiveCorrect, p.wrongCount], [true, 1, 2]);
  });

  test('câu chưa từng sai trả lời đúng thì không vào "Câu sai"', () async {
    await answer('Q0004', correct: true);
    expect(await repo.wrongList(), isEmpty);
    expect((await repo.allProgress())['Q0004']!.lastCorrect, isTrue);
  });

  test('mỗi lần trả lời ghi một dòng nhật ký', () async {
    await answer('Q0005', correct: false);
    now = now.add(const Duration(minutes: 1));
    await answer('Q0005', correct: true);
    final logs = await app.db.query(
      'answer_log',
      where: 'question_id = ?',
      whereArgs: ['Q0005'],
    );
    expect(logs, hasLength(2));
  });

  test('nhớ câu đang dở của từng chủ đề (FR-A13)', () async {
    expect(await repo.topicPosition('B', 'chapter-1'), isNull);
    await repo.saveTopicPosition('B', 'chapter-1', 'Q0010');
    await repo.saveTopicPosition('B', 'chapter-1', 'Q0011');
    await repo.saveTopicPosition('A1', 'chapter-1', 'Q0003');
    expect(await repo.topicPosition('B', 'chapter-1'), 'Q0011');
    expect(await repo.topicPosition('A1', 'chapter-1'), 'Q0003');
  });
}
