import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/exam_grader.dart';
import 'package:hoclaixe/features/exam/domain/exam_session.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/real_content.dart';

void main() {
  sqfliteFfiInit();
  final content = loadRealContent();
  final byId = {for (final q in content.questions) q.id: q};
  final structure = content.structures.firstWhere((s) => s.id == 'B-2025');
  final paper = const ExamGenerator().generate(
    structure: structure,
    bank: content.questions,
    random: Random(3),
  );

  late AppDatabase app;
  late ExamSessionRepository repo;
  var now = DateTime(2026, 10, 14, 9);

  setUp(() async {
    now = DateTime(2026, 10, 14, 9);
    app = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repo = ExamSessionRepository(app.db, clock: () => now);
  });
  tearDown(() => app.close());

  /// Grader the screen would pass to submit(): grades whatever answers the repository read from the database.
  ExamResult Function(List<int?>) graderFor(ExamSession s) =>
      (answers) => const ExamGrader().grade(
        paper: s.paper,
        structure: structure,
        questionsById: byId,
        answers: answers,
      );

  test('bắt đầu: lưu ảnh chụp đề, hạn giờ tuyệt đối, chưa có đáp án', () async {
    final s = await repo.start(paper, structure);
    expect(s.paper.questionIds, paper.questionIds);
    expect(s.paper.criticalQuestionId, paper.criticalQuestionId);
    expect(s.deadlineAt, now.add(const Duration(minutes: 20)));
    expect(s.status, ExamStatus.inProgress);
    expect(s.answers, everyElement(isNull));
  });

  test(
    'tối đa 1 bài thi dở (BR-09); bỏ bài dở thì bắt đầu được bài mới',
    () async {
      final s = await repo.start(paper, structure);
      expect(
        () => repo.start(paper, structure),
        throwsA(isA<OpenSessionExistsException>()),
      );
      await repo.abandon(s.id);
      expect(await repo.openSession(), isNull);
      expect((await repo.start(paper, structure)).id, isNot(s.id));
    },
  );

  test(
    'chọn và đổi đáp án: đọc lại từ DB luôn khớp lần chọn cuối (FR-A24)',
    () async {
      final s = await repo.start(paper, structure);
      await repo.saveAnswer(s.id, 0, 2);
      await repo.saveAnswer(s.id, 0, 1);
      await repo.saveAnswer(s.id, 5, 0);
      await repo.setFlag(s.id, 5, flagged: true);
      final reopened = (await repo.openSession())!;
      expect(
        [reopened.answers[0], reopened.answers[5], reopened.answers[1]],
        [1, 0, null],
      );
      expect(reopened.flagged[5], isTrue);
    },
  );

  test('nộp 2 lần chỉ chấm và ghi nhật ký 1 lần (FR-A26)', () async {
    var s = await repo.start(paper, structure);
    for (var i = 0; i < s.paper.length; i++) {
      await repo.saveAnswer(
        s.id,
        i,
        byId[s.paper.questionIds[i]]!.correctIndex,
      );
    }
    s = (await repo.byId(s.id))!;
    expect((await repo.submit(s, graderFor(s)))?.score, 30);
    expect(await repo.submit(s, graderFor(s)), isNull);
    final logs = await app.db.query(
      'answer_log',
      where: 'session_id = ?',
      whereArgs: [s.id],
    );
    expect(logs, hasLength(s.paper.length));
    final row = (await app.db.query(
      'exam_session',
      where: 'id = ?',
      whereArgs: [s.id],
    )).single;
    expect([row['status'], row['score'], row['passed']], ['submitted', 30, 1]);
  });

  test('sau khi nộp không sửa được đáp án nữa', () async {
    final s = await repo.start(paper, structure);
    await repo.submit(s, graderFor(s));
    expect(() => repo.saveAnswer(s.id, 0, 1), throwsStateError);
  });

  test('nộp bài: câu sai và câu bỏ trống vào "Câu sai" (FR-A40)', () async {
    final s = await repo.start(paper, structure);
    final wrongPick =
        (byId[s.paper.questionIds[0]]!.correctIndex + 1) %
        byId[s.paper.questionIds[0]]!.options.length;
    await repo.saveAnswer(
      s.id,
      0,
      wrongPick,
    ); // sai câu 0, các câu khác bỏ trống
    final fresh = (await repo.byId(s.id))!;
    await repo.submit(fresh, graderFor(fresh));
    final wrong = await ProgressRepository(app.db).wrongList();
    expect(wrong, s.paper.questionIds.toSet());
  });

  test('mở lại sau khi hết giờ: phiên dở báo đã hết giờ (FR-A25)', () async {
    await repo.start(paper, structure);
    now = now.add(const Duration(minutes: 19, seconds: 59));
    expect((await repo.openSession())!.isExpired(now), isFalse);
    now = now.add(const Duration(days: 3));
    final s = (await repo.openSession())!;
    expect(s.isExpired(now), isTrue);
    expect(s.remaining(now), Duration.zero);
  });

  test('cấu trúc lấy từ dữ liệu thật: thời gian 20 phút cho hạng B', () {
    expect(structure, isA<ExamStructure>());
    expect(structure.durationMinutes, 20);
  });

  test('nộp bằng bản phiên cũ trên màn hình vẫn chấm theo đáp án đã lưu trong DB (FR-A24)', () async {
    final stale = await repo.start(
      paper,
      structure,
    ); // answers all null in this copy
    for (var i = 0; i < stale.paper.length; i++) {
      await repo.saveAnswer(
        stale.id,
        i,
        byId[stale.paper.questionIds[i]]!.correctIndex,
      );
    }
    final result = (await repo.submit(stale, graderFor(stale)))!;
    expect([result.score, result.passed], [30, true]);
  });
}
