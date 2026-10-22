import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/router.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/exam_grader.dart';
import 'package:hoclaixe/features/exam/domain/exam_session.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final start = DateTime(2026, 10, 21, 9);
  final a1 = StructurePicker.pick(
    content.structures,
    'A1',
    start,
  )!.structure; // 25 câu · 19 phút · đạt 21

  late AppDatabase db;
  late DateTime now;

  ExamSessionRepository sessions() =>
      ExamSessionRepository(db.db, clock: () => now);

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: onboarded('A1'),
        now: start,
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> setUpApp(WidgetTester tester) async {
    db = await openTestDatabase(tester);
    now = start;
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  /// Home → Thi thử → Đề số [set] → Bắt đầu.
  Future<void> startFixedTest(WidgetTester tester, {int set = 1}) async {
    await tap(tester, find.text(S.practiceExam));
    await tap(tester, find.text(S.fixedTest(set)));
    await tap(tester, find.text(S.startTest));
  }

  QuestionView currentView(WidgetTester tester, int position) =>
      tester.widget<QuestionView>(
        find.byWidgetPredicate(
          (w) => w is QuestionView && w.position == position,
        ),
      );

  /// Answers the question on screen at [position]; [correct] picks the right or a wrong option.
  Future<int> answer(
    WidgetTester tester,
    int position, {
    required bool correct,
  }) async {
    final q = currentView(tester, position).question;
    final option = correct ? q.correctIndex : (q.correctIndex == 0 ? 1 : 0);
    final view = find.byWidgetPredicate(
      (w) => w is QuestionView && w.position == position,
    );
    await tap(
      tester,
      find.descendant(of: view, matching: find.text(q.options[option])),
    );
    return option;
  }

  /// A cell of the question strip; its label is "Câu n" or "Câu n, Chưa trả lời".
  Finder stripCell(int n) => find.bySemanticsLabel(RegExp('^${S.questionNumber(n)}(,|\$)'));

  Future<void> next(WidgetTester tester) =>
      tap(tester, find.byTooltip(S.nextQuestion));

  Future<ExamSession?> stored(WidgetTester tester, int id) async =>
      tester.runAsync<ExamSession?>(() => sessions().byId(id));

  /// Moves the clock and lets the 1-second ticker run.
  Future<void> advance(WidgetTester tester, Duration d) async {
    now = now.add(d);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'chọn đề: đề ngẫu nhiên + lưới 20 đề, chưa làm đề nào (ST-11 AC1)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await tap(tester, find.text(S.practiceExam));
      expect(find.text(S.randomTest), findsOneWidget);
      expect(find.text(S.fixedDone(0, 20)), findsOneWidget);
      expect(find.text(S.fixedTest(1)), findsOneWidget);
      await tester.ensureVisible(find.text(S.fixedTest(20)));
      expect(find.text(S.fixedTest(20)), findsOneWidget);
    },
  );

  testWidgets(
    'thông tin đề: số câu, thời gian, điểm đạt, câu điểm liệt (ST-08 AC1)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await tap(tester, find.text(S.practiceExam));
      await tap(tester, find.text(S.randomTest));
      expect(find.text(S.questionCount(a1.questionCount)), findsOneWidget);
      expect(find.text(S.minutes(a1.durationMinutes)), findsOneWidget);
      expect(find.text(S.correctAnswers(a1.passScore)), findsOneWidget);
      expect(find.text(S.criticalRule), findsOneWidget);
      expect(find.text(S.startTest), findsOneWidget);
    },
  );

  testWidgets(
    'đang thi: đồng hồ, số câu, lưới câu; đáp án lưu DB ngay, đổi được; không lộ đúng/sai (ST-08 AC2, AC3)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester);
      expect(find.text(S.questionOfTotal(1, 25)), findsOneWidget);
      expect(
        find.text(S.timerLabel(Duration(minutes: a1.durationMinutes))),
        findsOneWidget,
      );

      final first = await answer(tester, 1, correct: false);
      expect(
        (await stored(tester, 1))!.answers.first,
        first,
        reason: 'đã ghi xuống DB',
      );
      final second = await answer(tester, 1, correct: true);
      expect(
        (await stored(tester, 1))!.answers.first,
        second,
        reason: 'đổi đáp án cũng ghi ngay',
      );
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text(S.criticalBadge), findsNothing);

      await tap(tester, stripCell(7));
      expect(find.text(S.questionOfTotal(7, 25)), findsOneWidget);
      await tap(tester, find.byTooltip(S.previousQuestion));
      expect(find.text(S.questionOfTotal(6, 25)), findsOneWidget);
      await tap(tester, stripCell(1));
      expect(
        currentView(tester, 1).selectedIndex,
        second,
        reason: 'quay lại câu cũ vẫn thấy đáp án đã chọn',
      );
    },
  );

  testWidgets(
    'còn 60 giây đổi màu; về 00:00 tự nộp kể cả khi bảng thoát đang mở (ST-09 AC1)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester);
      await answer(tester, 1, correct: true);

      await advance(
        tester,
        Duration(minutes: a1.durationMinutes) - const Duration(seconds: 30),
      );
      expect(find.text('00:30'), findsOneWidget);

      await tap(tester, find.text(S.submit));
      expect(find.text(S.endTestTitle), findsOneWidget);
      await advance(tester, const Duration(seconds: 30));
      expect(find.text(S.endTestTitle), findsNothing);
      expect(find.text(S.resultTitle), findsOneWidget);
      expect((await stored(tester, 1))!.status, ExamStatus.submitted);
    },
  );

  testWidgets(
    'bảng thoát: lưu tạm và thoát → bài còn dở, thẻ Tiếp tục ở màn chính; làm tiếp giữ đáp án (ST-09 AC2)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester);
      final chosen = await answer(tester, 1, correct: false);

      await tap(tester, find.text(S.submit));
      for (final option in [
        S.submitAndGrade,
        S.saveAndExit,
        S.discardAndExit,
        S.keepGoing,
      ]) {
        expect(find.text(option), findsOneWidget, reason: option);
      }
      await tap(tester, find.text(S.saveAndExit));
      expect(find.widgetWithText(AppBar, S.practiceExam), findsOneWidget, reason: 'về màn chọn đề');
      expect((await stored(tester, 1))!.status, ExamStatus.inProgress);

      await tester.pageBack();
      await tester.pumpAndSettle();
      // home was scrolled down to reach the "Thi thử" tile; the resume card is at the top
      await tester.fling(find.byType(Scrollable).first, const Offset(0, 800), 2000);
      await tester.pumpAndSettle();
      await tap(tester, find.text(S.resumeExam));
      expect(currentView(tester, 1).selectedIndex, chosen);
    },
  );

  testWidgets(
    'nút quay lại cũng mở bảng thoát; không lưu và thoát (xác nhận) → bỏ bài (ST-09 AC2)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester);
      await answer(tester, 1, correct: true);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(S.endTestTitle), findsOneWidget);
      await tap(tester, find.text(S.discardAndExit));
      expect(find.text(S.discardConfirmTitle), findsOneWidget);
      await tap(tester, find.widgetWithText(FilledButton, S.discard));
      expect((await stored(tester, 1))!.status, ExamStatus.abandoned);
      expect(find.widgetWithText(AppBar, S.practiceExam), findsOneWidget);
    },
  );

  testWidgets(
    'mở lại app có bài dở → hỏi "Tiếp tục bài thi?", giờ còn lại theo giờ thực (ST-09 AC3)',
    (tester) async {
      await setUpApp(tester);
      final paper = const ExamGenerator().generateFixed(
        structure: a1,
        bank: content.questions,
        setNo: 3,
        contentVersion: content.version,
      );
      await tester.runAsync(() async {
        final s = await sessions().start(paper, a1);
        await sessions().saveAnswer(s.id, 0, 2);
      });
      now = start.add(const Duration(minutes: 5));
      await openApp(tester);
      expect(find.text(S.resumePromptTitle), findsOneWidget);
      expect(
        find.text(
          S.resumePromptBody('A1', Duration(minutes: a1.durationMinutes - 5)),
        ),
        findsOneWidget,
      );

      await tap(tester, find.text(S.resume));
      expect(
        find.text(S.timerLabel(Duration(minutes: a1.durationMinutes - 5))),
        findsOneWidget,
      );
      expect(currentView(tester, 1).selectedIndex, 2);
    },
  );

  testWidgets(
    'mở lại app khi bài dở đã hết giờ → tự nộp và hiện kết quả (ST-09 AC3, FR-A25)',
    (tester) async {
      await setUpApp(tester);
      final paper = const ExamGenerator().generateFixed(
        structure: a1,
        bank: content.questions,
        setNo: 4,
        contentVersion: content.version,
      );
      await tester.runAsync(() => sessions().start(paper, a1));
      now = start.add(const Duration(hours: 2));
      await openApp(tester);
      expect(find.text(S.resultTitle), findsOneWidget);
      expect(
        find.text(S.failed),
        findsOneWidget,
        reason: 'không trả lời câu nào',
      );
      expect((await stored(tester, 1))!.status, ExamStatus.submitted);
    },
  );

  testWidgets(
    'nộp bài: kết quả khớp đáp án đã lưu, lý do trượt, câu sai vào "Câu sai"; xem lại + lọc (ST-10, ST-09 AC4)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester);
      for (var p = 1; p <= 5; p++) {
        await answer(
          tester,
          p,
          correct: p != 2,
        ); // câu 2 sai, câu 6–25 bỏ trống
        if (p < 5) await next(tester);
      }
      await tap(tester, find.text(S.submit));
      expect(find.text(S.unansweredWarning(20)), findsOneWidget);
      await tap(tester, find.text(S.submitAndGrade));

      expect(find.text(S.failed), findsOneWidget);
      expect(find.text(S.resultScore(4, 25)), findsOneWidget);
      expect(find.text(S.resultCounts(4, 1, 20)), findsOneWidget);
      expect(find.text(S.failNotEnough(4, a1.passScore)), findsOneWidget);
      final saved = (await stored(tester, 1))!;
      expect(saved.status, ExamStatus.submitted);
      expect(saved.answers.whereType<int>().length, 5);
      final wrong = (await tester.runAsync(
        () => ProgressRepository(db.db).wrongList(),
      ))!;
      expect(wrong, hasLength(21), reason: '1 câu sai + 20 câu bỏ trống');
      expect(
        (await tester.runAsync(
          () => sessions().submit(saved, (a) => const ExamGrader().grade(paper: saved.paper, structure: a1, questionsById: {for (final q in content.questions) q.id: q}, answers: a)),
        )),
        isNull,
        reason: 'nộp lần hai không tạo kết quả mới',
      );

      await tap(tester, find.text(S.reviewTest));
      expect(find.byType(QuestionView), findsWidgets);
      await tap(tester, find.text(S.onlyWrong));
      await tester.scrollUntilVisible(find.text(S.questionNumber(25)), 300);
      expect(
        find.text(S.questionNumber(1)),
        findsNothing,
        reason: 'câu 1 đúng bị lọc',
      );
      expect(find.text(S.questionNumber(25)), findsOneWidget);
    },
  );

  testWidgets(
    'đề cố định: sau khi nộp, lưới ghi trạng thái + điểm; làm lại cùng danh sách câu (ST-11)',
    (tester) async {
      await setUpApp(tester);
      await openApp(tester);
      await startFixedTest(tester, set: 2);
      await tap(tester, find.text(S.submit));
      await tap(tester, find.text(S.submitAndGrade));
      await tap(tester, find.text(S.anotherTest));
      expect(find.text(S.fixedDone(1, 20)), findsOneWidget);
      expect(find.text(S.failedShort), findsOneWidget);
      expect(find.text(S.scoreOf(0, 25)), findsOneWidget);

      await tap(tester, find.text(S.fixedTest(2)));
      await tap(tester, find.text(S.startTest));
      final first = (await stored(tester, 1))!.paper.questionIds;
      final again = (await stored(tester, 2))!.paper.questionIds;
      expect(again, first);
    },
  );

  // ---- regressions from Kiệt's review (22/10) ----

  testWidgets(
    'chọn đáp án rồi nhảy câu trong lúc đang lưu → đáp án ghi và tô đúng câu đã chọn (review High)',
    (tester) async {
      await setUpApp(tester);
      final gate = _SlowSaves(db.db, () => now);
      await tester.pumpWidget(
        testApp(content: content, db: db, store: onboarded('A1'), now: start, clock: () => now, examSessions: (_) => gate),
      );
      await tester.pumpAndSettle();
      await startFixedTest(tester);
      final q = currentView(tester, 1).question;
      final view = find.byWidgetPredicate((w) => w is QuestionView && w.position == 1);

      gate.hold = true;
      await tester.tap(find.descendant(of: view, matching: find.text(q.options[1])));
      await tester.pump();
      await tap(tester, stripCell(6)); // moved to question 6 while question 1 is still being saved
      gate.release();
      await tester.pumpAndSettle();

      final saved = (await stored(tester, 1))!;
      expect(saved.answers[0], 1, reason: 'câu 1 nhận đáp án');
      expect(saved.answers[5], isNull, reason: 'câu 6 không bị ghi nhầm');
      expect(find.bySemanticsLabel(RegExp('^${S.questionNumber(6)}, ')), findsOneWidget, reason: 'ô 6 vẫn "chưa trả lời"');
      await tap(tester, stripCell(1));
      expect(currentView(tester, 1).selectedIndex, 1, reason: 'câu 1 hiện đáp án đã lưu');
    },
  );

  testWidgets('bấm hai đáp án liên tiếp rất nhanh → đáp án sau cùng được lưu (review Low)', (tester) async {
    await setUpApp(tester);
    await openApp(tester);
    await startFixedTest(tester);
    final q = currentView(tester, 1).question;
    final view = find.byWidgetPredicate((w) => w is QuestionView && w.position == 1);
    await tester.tap(find.descendant(of: view, matching: find.text(q.options[0])));
    await tester.tap(find.descendant(of: view, matching: find.text(q.options[1])));
    await tester.pumpAndSettle();
    expect((await stored(tester, 1))!.answers[0], 1);
    expect(currentView(tester, 1).selectedIndex, 1);
  });

  testWidgets('Kết quả hiện điểm đã lưu lúc nộp (khớp Lịch sử); Xem lại bài của mã không tồn tại báo lỗi (review)',
      (tester) async {
    await setUpApp(tester);
    await openApp(tester);
    await startFixedTest(tester);
    await answer(tester, 1, correct: true);
    await tap(tester, find.text(S.submit));
    await tap(tester, find.text(S.submitAndGrade));
    expect(find.text(S.resultScore(1, 25)), findsOneWidget);

    // the stored score is what every screen shows, even if grading today would differ
    await tester.runAsync(() => db.db.update('exam_session', {'score': 7}, where: 'id = 1'));
    await tap(tester, find.text(S.anotherTest));
    await tap(tester, find.text(S.fixedTest(1)));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(S.scoreOf(7, 25)), findsOneWidget, reason: 'ô đề số 1');

    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    unawaited(router.push(Routes.examResult(1)));
    await tester.pumpAndSettle();
    expect(find.text(S.resultScore(7, 25)), findsOneWidget, reason: 'màn Kết quả dùng điểm đã lưu');

    unawaited(router.push(Routes.examReview(999)));
    await tester.pumpAndSettle();
    expect(find.text(S.examError), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

/// Repository whose saves wait until the test releases them — reproduces a slow phone (review 22/10).
class _SlowSaves extends ExamSessionRepository {
  _SlowSaves(super.db, DateTime Function() clock) : super(clock: clock);

  bool hold = false;
  Completer<void>? _gate;

  void release() {
    hold = false;
    _gate?.complete();
  }

  @override
  Future<void> saveAnswer(int sessionId, int position, int? selectedIndex) async {
    if (hold) await (_gate = Completer<void>()).future;
    return super.saveAnswer(sessionId, position, selectedIndex);
  }
}
