import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/exam_grader.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/stats/data/stats_providers.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/features/study/data/study_providers.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 21, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final pool = questionPool(content.questions, 'A1', pool: a1.pool);
  final byId = {for (final q in content.questions) q.id: q};

  group('Câu hay sai (FR-A51)', () {
    StudyTopic frequent(Map<String, int> counts) => resolveTopic(
      StudyTopic.frequentId,
      pool: pool,
      licenseClass: 'A1',
      wrongIds: const {},
      wrongCounts: counts,
    )!;

    test('sắp theo tổng số lần sai giảm dần, hòa thì theo số câu; chỉ câu sai ≥ 1 trong bộ câu của hạng', () {
      final t = frequent({
        pool[5].id: 2,
        pool[1].id: 5,
        pool[3].id: 2,
        'Q0599': 9,
        pool[7].id: 0,
      });
      expect(t.questionIds, [pool[1].id, pool[3].id, pool[5].id]);
      expect(t.kind, TopicKind.frequent);
      expect(t.isSnapshot, isTrue);
    });

    test('làm "Câu hay sai" ghi chế độ study, "Ôn câu sai" ghi wrong (review)', () {
      final t = frequent({pool[0].id: 1});
      expect(answerModeOf(t), AnswerMode.study);
      final wrong = resolveTopic(StudyTopic.wrongOf(StudyTopic.allId), pool: pool, licenseClass: 'A1', wrongIds: {pool[0].id})!;
      expect(answerModeOf(wrong), AnswerMode.wrong);
    });

    test('tối đa 50 câu', () {
      final t = frequent({for (var i = 0; i < 80; i++) pool[i].id: 1 + i % 4});
      expect(t.questions, hasLength(StudyTopic.frequentLimit));
      expect(
        t.questions.first.id,
        pool[3].id,
        reason: '4 lần sai, số câu nhỏ nhất',
      );
    });
  });

  group('lịch sử thi + số lần sai (repository)', () {
    late AppDatabase app;
    setUp(() async {
      sqfliteFfiInit();
      app = await AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    });
    tearDown(() => app.close());

    test('lịch sử chỉ gồm bài đã nộp của hạng, mới nhất trước; tổng số lần sai không reset khi đúng', () async {
      var t = now;
      final sessions = ExamSessionRepository(app.db, clock: () => t);
      const gen = ExamGenerator();
      Future<void> takeTest(int set, {bool submit = true}) async {
        final paper = gen.generateFixed(
          structure: a1,
          bank: content.questions,
          setNo: set,
          contentVersion: content.version,
        );
        final s = await sessions.start(paper, a1);
        if (submit) {
          await sessions.submit(
            s,
            (a) => const ExamGrader().grade(
              paper: paper,
              structure: a1,
              questionsById: byId,
              answers: a,
            ),
          );
        }
        t = t.add(const Duration(hours: 1));
      }

      await takeTest(1);
      await takeTest(2);
      await takeTest(3, submit: false);
      final history = await sessions.history('A1');
      expect(history.map((h) => h.fixedSetNo), [2, 1]);
      expect(history.first.total, 25);
      expect(await sessions.history('B'), isEmpty);
      expect(testStats(history), (
        taken: 2,
        passRatePercent: 0,
        latest: history.first,
      ));

      final progress = ProgressRepository(app.db, clock: () => t);
      final q = pool[0];
      await progress.recordAnswer(
        questionId: q.id,
        mode: AnswerMode.study,
        selectedIndex: 9,
        isCorrect: false,
      );
      await progress.recordAnswer(
        questionId: q.id,
        mode: AnswerMode.study,
        selectedIndex: q.correctIndex,
        isCorrect: true,
      );
      await progress.recordAnswer(
        questionId: q.id,
        mode: AnswerMode.study,
        selectedIndex: 9,
        isCorrect: false,
      );
      expect((await progress.wrongCounts())[q.id], greaterThanOrEqualTo(2));
    });
  });

  testWidgets(
    'Thống kê: lần thi, tỉ lệ đạt, điểm gần nhất, lịch sử → xem lại; Câu hay sai mở danh sách (ST-15)',
    (tester) async {
      final db = await openTestDatabase(tester);
      await tester.runAsync(() async {
        final sessions = ExamSessionRepository(
          db.db,
          clock: () => now.subtract(const Duration(hours: 1)),
        );
        final paper = const ExamGenerator().generateFixed(
          structure: a1,
          bank: content.questions,
          setNo: 5,
          contentVersion: content.version,
        );
        final s = await sessions.start(paper, a1);
        await sessions.saveAnswer(
          s.id,
          0,
          byId[paper.questionIds[0]]!.correctIndex,
        );
        await sessions.submit(
          s,
          (a) => const ExamGrader().grade(
            paper: paper,
            structure: a1,
            questionsById: byId,
            answers: a,
          ),
        );
      });
      await tester.pumpWidget(
        testApp(content: content, db: db, store: onboarded('A1'), now: now),
      );
      await tester.pumpAndSettle();
      await openTab(tester, S.statistics);

      expect(find.text(S.testsTaken), findsOneWidget);
      expect(find.text(S.percent(0)), findsWidgets);
      expect(find.text(S.scoreOf(1, 25)), findsWidgets);
      await tester.scrollUntilVisible(
        find.text(S.topicCritical),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text(S.topicCritical),
        findsOneWidget,
        reason: 'tiến độ theo chủ đề',
      );

      await tester.scrollUntilVisible(
        find.text(S.fixedTest(5)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(S.fixedTest(5)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, S.reviewTest), findsOneWidget);
      expect(find.byType(QuestionView), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(S.frequentWrong),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(S.frequentWrong));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, S.frequentWrong), findsOneWidget);
      expect(
        find.text(S.questionOfTotal(1, 24)),
        findsOneWidget,
        reason: '24 câu sai/bỏ trống trong bài thi',
      );
    },
  );
}
