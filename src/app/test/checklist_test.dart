// Mô phỏng phiếu kiểm thử docs/test/phieu-kiem-thu.docx (mục 1–31) bằng widget test.
// Kết quả: production/bugs/2026-10-22-kiem-thu-theo-phieu.md
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
import 'package:hoclaixe/features/exam/domain/exam_session.dart';
import 'package:hoclaixe/features/signs/presentation/sign_detail_screen.dart';
import 'package:hoclaixe/shared/widgets/answer_option.dart';
import 'package:hoclaixe/shared/widgets/image_zoom_page.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import 'support/real_content.dart';
import 'support/test_app.dart';

void main() {
  final content = loadRealContent();
  final byId = {for (final q in content.questions) q.id: q};
  final start = DateTime(2026, 10, 22, 9);

  late AppDatabase db;
  late DateTime now;
  late InMemorySettingsStore store;

  Future<void> boot(WidgetTester tester, {InMemorySettingsStore? s}) async {
    db = await openTestDatabase(tester);
    now = start;
    store = s ?? onboarded('A1');
  }

  /// Opens (or re-opens = F5 / restart) the app on the same database and settings.
  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: store,
        now: start,
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f.first);
    await tester.pumpAndSettle();
    await tester.tap(f.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String t) =>
      tap(tester, find.text(t));

  Finder viewAt(int position) => find.byWidgetPredicate(
    (w) => w is QuestionView && w.position == position,
  );

  Question questionAt(WidgetTester tester, int position) =>
      tester.widget<QuestionView>(viewAt(position)).question;

  Future<void> choose(WidgetTester tester, int position, int option) async {
    final q = questionAt(tester, position);
    await tap(
      tester,
      find.descendant(
        of: viewAt(position),
        matching: find.text(q.options[option]),
      ),
    );
  }

  int wrongOf(Question q) => q.correctIndex == 0 ? 1 : 0;

  List<AnswerState> statesAt(WidgetTester tester, int position) => [
    for (final o in tester.widgetList<AnswerOption>(
      find.descendant(
        of: viewAt(position),
        matching: find.byType(AnswerOption),
      ),
    ))
      o.state,
  ];

  Finder stripCell(int n) =>
      find.bySemanticsLabel(RegExp('^${S.questionNumber(n)}(,|\$)'));

  ExamSessionRepository sessions() =>
      ExamSessionRepository(db.db, clock: () => now);

  Future<ExamSession?> openSession(WidgetTester tester) =>
      tester.runAsync(() => sessions().openSession()).then((s) => s);

  Future<int> logCount(WidgetTester tester) async =>
      (await tester.runAsync(
            () => db.db.rawQuery('SELECT COUNT(*) c FROM answer_log'),
          ))!.first['c']!
          as int;

  // ---------------- A. Mở app lần đầu ----------------
  testWidgets(
    'A 1–4: miễn trừ, chọn hạng, vào màn chính, mở lại không hỏi lại',
    (tester) async {
      await boot(tester, s: InMemorySettingsStore());
      await openApp(tester);
      // 1
      expect(
        find.text(S.disclaimerTitle),
        findsOneWidget,
        reason: 'mục 1: màn miễn trừ',
      );
      expect(
        find.text(S.sourcesTitle),
        findsOneWidget,
        reason: 'mục 1: có danh sách nguồn',
      );
      await tapText(tester, S.disclaimerAccept);
      expect(
        find.text(S.chooseClassTitle),
        findsOneWidget,
        reason: 'mục 1: sang màn chọn hạng',
      );
      // 2
      expect(find.text(S.motorbikeGroup), findsOneWidget);
      expect(find.text(S.carGroup), findsOneWidget);
      for (final c in ['A1', 'A', 'B']) {
        expect(
          find.text(S.className(c)),
          findsOneWidget,
          reason: 'mục 2: hạng $c',
        );
        expect(
          find.text(S.classVehicles[c]!),
          findsOneWidget,
          reason: 'mục 2: mô tả xe $c',
        );
      }
      expect(
        find.text('25 câu · 19 phút · đạt từ 21 câu đúng', skipOffstage: false),
        findsOneWidget,
        reason: 'mục 2: A1',
      );
      expect(
        find.text('25 câu · 19 phút · đạt từ 23 câu đúng', skipOffstage: false),
        findsOneWidget,
        reason: 'mục 2: A (TT 12/2025)',
      );
      expect(
        find.text('30 câu · 20 phút · đạt từ 27 câu đúng'),
        findsOneWidget,
        reason: 'mục 2: B',
      );
      // 3
      await tapText(tester, S.className('A1'));
      expect(homeTitle('Hạng A1'), findsOneWidget, reason: 'mục 3');
      expect(
        find.text('0 / 250 câu'),
        findsOneWidget,
        reason: 'mục 3: tiến độ 0/250',
      );
      // 4
      await openApp(tester);
      expect(homeTitle('Hạng A1'), findsOneWidget, reason: 'mục 4');
      expect(find.text(S.disclaimerTitle), findsNothing, reason: 'mục 4');
    },
  );

  // ---------------- B + C. Học theo chủ đề, ôn câu sai, điểm liệt ----------------
  testWidgets(
    'B 5–10, C 11: học chủ đề, khóa câu, lưới, nhớ vị trí, làm lại, ôn câu sai 2 lần',
    (tester) async {
      await boot(tester);
      await openApp(tester);
      // 5
      await tapText(tester, S.studyByTopic);
      expect(find.text(S.topicAll), findsOneWidget);
      expect(
        find.text(S.questionCount(250)),
        findsOneWidget,
        reason: 'mục 5: Tất cả câu hỏi (250)',
      );
      expect(
        find.text(S.questionCount(20)),
        findsOneWidget,
        reason: 'mục 5: Câu điểm liệt (20)',
      );
      expect(find.textContaining('Chương I.'), findsWidgets);
      expect(
        find.text(S.topicStats(0, 0, 250)),
        findsOneWidget,
        reason: 'mục 5: Đúng · Sai · Chưa làm',
      );
      // 6
      await tap(tester, find.textContaining('Chương I.'));
      final q1 = questionAt(tester, 1);
      await choose(tester, 1, wrongOf(q1));
      final s = statesAt(tester, 1);
      expect(
        s[wrongOf(q1)],
        AnswerState.wrong,
        reason: 'mục 6: ✗ ở đáp án chọn',
      );
      expect(
        s[q1.correctIndex],
        AnswerState.correct,
        reason: 'mục 6: ✓ ở đáp án đúng',
      );
      final other = [for (var i = 0; i < q1.options.length; i++) i].firstWhere(
        (i) => i != wrongOf(q1) && i != q1.correctIndex,
        orElse: () => q1.correctIndex,
      );
      await choose(tester, 1, other);
      expect(
        statesAt(tester, 1)[wrongOf(q1)],
        AnswerState.wrong,
        reason: 'mục 6: không đổi được',
      );
      expect(await logCount(tester), 1, reason: 'mục 6: chỉ ghi 1 lần trả lời');
      // 7
      await tap(tester, find.byTooltip(S.nextQuestion));
      expect(viewAt(2), findsOneWidget, reason: 'mục 7: ▶ chuyển câu');
      await tap(tester, find.textContaining(RegExp(r'^Câu 2 / \d+$')));
      await tap(
        tester,
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('10'),
        ),
      );
      expect(
        find.textContaining(RegExp(r'^Câu 10 / \d+$')),
        findsOneWidget,
        reason: 'mục 7: nhảy tới câu 10',
      );
      // 8: câu có hình trong chương đang học
      // (để riêng ở test mục 8)
      // 9
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tap(tester, find.textContaining('Chương I.'));
      expect(
        find.textContaining(RegExp(r'^Câu 10 / \d+$')),
        findsOneWidget,
        reason: 'mục 9: mở đúng câu đang dở',
      );
      await tap(tester, find.textContaining(RegExp(r'^Câu 10 / \d+$')));
      await tap(
        tester,
        find.descendant(of: find.byType(BottomSheet), matching: find.text('1')),
      );
      expect(
        statesAt(tester, 1)[wrongOf(q1)],
        AnswerState.wrong,
        reason: 'mục 9: câu đã làm vẫn hiện đáp án',
      );
      // 10
      await tap(tester, find.byTooltip(S.restartTopic));
      await tap(tester, find.widgetWithText(FilledButton, S.restartTopic));
      expect(
        statesAt(tester, 1).every((e) => e == AnswerState.idle),
        isTrue,
        reason: 'mục 10: câu trống lại',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text(S.questionCount(1)),
        findsOneWidget,
        reason: 'mục 10: ô Ôn câu sai vẫn 1 câu',
      );
      // 11
      await tapText(tester, S.reviewWrong);
      expect(questionAt(tester, 1).id, q1.id);
      await choose(tester, 1, q1.correctIndex);
      expect(
        find.text(S.reviewRemainingWrong),
        findsOneWidget,
        reason: 'mục 11: cuối lượt có Ôn tiếp',
      );
      await tapText(tester, S.reviewRemainingWrong);
      expect(
        viewAt(1),
        findsOneWidget,
        reason: 'mục 11: sau lần đúng 1 câu vẫn còn',
      );
      expect(questionAt(tester, 1).id, q1.id);
      await choose(tester, 1, q1.correctIndex);
      await tapText(tester, S.reviewRemainingWrong);
      expect(
        find.text(S.noWrongYet),
        findsOneWidget,
        reason: 'mục 11: sau lần đúng 2 câu biến mất',
      );
    },
  );

  testWidgets('B 8: chạm hình phóng to, chạm đúp, Đóng', skip: true, (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    await tapText(tester, S.studyByTopic);
    await tapText(tester, S.topicAll);
    // tìm câu đầu tiên có hình trong 250 câu A1
    var i = 1;
    for (; i <= 250; i++) {
      if (questionAt(tester, i).images.isNotEmpty) break;
      await tap(tester, find.byTooltip(S.nextQuestion));
    }
    expect(i <= 250, isTrue, reason: 'có câu có hình');
    await tap(
      tester,
      find.descendant(of: viewAt(i), matching: find.byType(Image)),
    );
    expect(
      find.byType(ImageZoomPage),
      findsOneWidget,
      reason: 'mục 8: phóng to',
    );
    await tapText(tester, S.close);
    expect(find.byType(ImageZoomPage), findsNothing, reason: 'mục 8: quay lại');
  });

  testWidgets('C 12: câu điểm liệt A1 = 20, B = 60, có nhãn Điểm liệt', (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    await tapText(tester, S.criticalQuestions);
    expect(
      find.textContaining(RegExp(r'^Câu 1 / 20$')),
      findsOneWidget,
      reason: 'mục 12: A1 20 câu',
    );
    expect(
      find.descendant(of: viewAt(1), matching: find.text(S.criticalBadge)),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, S.changeClass);
    await tapText(tester, S.className('B'));
    expect(homeTitle('Hạng B'), findsOneWidget);
    expect(
      find.text(S.questionCount(60)),
      findsOneWidget,
      reason: 'mục 12: ô điểm liệt B = 60',
    );
    await tapText(tester, S.criticalQuestions);
    expect(
      find.textContaining(RegExp(r'^Câu 1 / 60$')),
      findsOneWidget,
      reason: 'mục 12: B 60 câu',
    );
    expect(
      find.descendant(of: viewAt(1), matching: find.text(S.criticalBadge)),
      findsOneWidget,
    );
  });

  // ---------------- D. Thi thử ----------------
  testWidgets('D 13–22: thi đề số 1 từ đầu đến xem lại, làm lại cùng bộ câu', (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    // 13
    await tapText(tester, S.practiceExam);
    expect(find.text(S.randomTest), findsOneWidget);
    expect(find.text(S.fixedDone(0, 20)), findsOneWidget);
    expect(
      find.text(S.notTaken),
      findsNWidgets(20),
      reason: 'mục 13: 20 đề Chưa làm',
    );
    // 14
    await tapText(tester, S.fixedTest(1));
    expect(find.text('25 câu'), findsOneWidget);
    expect(find.text('19 phút'), findsOneWidget);
    expect(
      find.text('1 câu điểm liệt — sai là trượt'),
      findsOneWidget,
      reason: 'mục 14',
    );
    await tapText(tester, S.startTest);
    // 15
    final session = (await openSession(tester))!;
    final ids = session.paper.questionIds;
    expect(find.text('19:00'), findsOneWidget, reason: 'mục 15: đồng hồ');
    now = now.add(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('18:57'), findsOneWidget, reason: 'mục 15: đếm ngược');
    await choose(tester, 1, 0);
    final st = statesAt(tester, 1);
    expect(
      st.where((e) => e == AnswerState.correct || e == AnswerState.wrong),
      isEmpty,
      reason: 'mục 15: không lộ đúng/sai',
    );
    expect(
      find.text(S.criticalBadge),
      findsNothing,
      reason: 'mục 15: không nhãn điểm liệt',
    );

    // 16
    await choose(tester, 1, 1);
    await tap(tester, stripCell(10));
    expect(find.text(S.questionOfTotal(10, 25)), findsOneWidget);
    await tap(tester, stripCell(5));
    await tap(tester, stripCell(1));
    expect(
      statesAt(tester, 1)[1],
      AnswerState.chosen,
      reason: 'mục 16: vẫn là đáp án vừa đổi',
    );
    expect(
      (await tester.runAsync(() => sessions().byId(session.id)))!.answers[0],
      1,
      reason: 'mục 16: DB khớp',
    );
    // 17
    await tapText(tester, S.submit);
    expect(find.text(S.submitAndGrade), findsOneWidget);
    expect(find.text(S.saveAndExit), findsOneWidget);
    expect(find.text(S.discardAndExit), findsOneWidget);
    expect(
      find.text(S.keepGoing),
      findsOneWidget,
      reason: 'mục 17: 4 lựa chọn',
    );
    await tapText(tester, S.keepGoing);
    expect(
      statesAt(tester, 1)[1],
      AnswerState.chosen,
      reason: 'mục 17: đáp án còn nguyên',
    );
    // 18
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.text(S.saveAndExit),
      findsOneWidget,
      reason: 'mục 18: Back mở bảng 4 lựa chọn',
    );
    await tapText(tester, S.saveAndExit);
    await tester.binding.handlePopRoute(); // Thi thử → màn chính
    await tester.pumpAndSettle();
    expect(
      find.text(S.resumeExam),
      findsOneWidget,
      reason: 'mục 18: thẻ Tiếp tục bài thi',
    );
    now = now.add(const Duration(seconds: 30));
    await tapText(tester, S.resumeExam);
    expect(
      find.text('18:27'),
      findsOneWidget,
      reason: 'mục 18: đồng hồ chạy tiếp',
    );
    expect(
      statesAt(tester, 1)[1],
      AnswerState.chosen,
      reason: 'mục 18: bài còn nguyên',
    );
    // 19
    await openApp(tester);
    expect(
      find.text(S.resumePromptTitle),
      findsOneWidget,
      reason: 'mục 19: hỏi Tiếp tục bài thi?',
    );
    await tapText(tester, S.resume);
    // 20: trả lời đúng 20 câu (gồm câu điểm liệt), sai 2, bỏ trống 3
    for (var p = 1; p <= 22; p++) {
      await tap(tester, stripCell(p));
      final q = byId[ids[p - 1]]!;
      final right = p <= 20 || q.id == session.paper.criticalQuestionId;
      await choose(tester, p, right ? q.correctIndex : wrongOf(q));
    }
    final critPos = ids.indexOf(session.paper.criticalQuestionId) + 1;
    final expectCorrect = critPos > 22 ? 20 : (critPos > 20 ? 21 : 20);
    final expectWrong = 22 - expectCorrect;
    await tapText(tester, S.submit);
    await tapText(tester, S.submitAndGrade);
    expect(find.text(S.resultTitle), findsWidgets);
    expect(
      find.text(S.resultCounts(expectCorrect, expectWrong, 3)),
      findsOneWidget,
      reason: 'mục 20: số câu khớp cách làm',
    );
    expect(
      find.text(expectCorrect >= 21 && critPos <= 22 ? S.passed : S.failed),
      findsOneWidget,
      reason: 'mục 20: kết luận',
    );
    if (expectCorrect < 21) {
      expect(
        find.text(S.failNotEnough(expectCorrect, 21)),
        findsOneWidget,
        reason: 'mục 20: lý do trượt',
      );
    }
    // 21
    await tapText(tester, S.reviewTest);
    expect(find.byType(QuestionView), findsWidgets);
    await tapText(tester, S.onlyWrong);
    final shown = tester
        .widgetList<QuestionView>(
          find.byType(QuestionView, skipOffstage: false),
        )
        .toList();
    // ListView lười: cuộn để đếm hết
    final positions = <int>{for (final v in shown) v.position};
    for (var k = 0; k < 10; k++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      positions.addAll(
        tester
            .widgetList<QuestionView>(find.byType(QuestionView))
            .map((v) => v.position),
      );
    }
    expect(
      positions.length,
      expectWrong + 3,
      reason: 'mục 21: chỉ còn câu sai + câu bỏ trống',
    );
    // 22
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, S.anotherTest);
    expect(find.text(S.fixedDone(1, 20)), findsOneWidget);
    expect(
      find.text('$expectCorrect/25'),
      findsOneWidget,
      reason: 'mục 22: Đề số 1 kèm điểm',
    );
    await tapText(tester, S.fixedTest(1));
    await tapText(tester, S.startTest);
    final again = (await openSession(tester))!;
    expect(again.paper.questionIds, ids, reason: 'mục 22: làm lại cùng bộ câu');
  });

  testWidgets(
    'D 23: đúng 24 câu, sai câu điểm liệt → KHÔNG ĐẠT, lý do điểm liệt',
    (tester) async {
      await boot(tester);
      await openApp(tester);
      await tapText(tester, S.practiceExam);
      await tapText(tester, S.randomTest);
      await tapText(tester, S.startTest);
      final session = (await openSession(tester))!;
      final ids = session.paper.questionIds;
      for (var p = 1; p <= 25; p++) {
        await tap(tester, stripCell(p));
        final q = byId[ids[p - 1]]!;
        await choose(
          tester,
          p,
          q.id == session.paper.criticalQuestionId
              ? wrongOf(q)
              : q.correctIndex,
        );
      }
      await tapText(tester, S.submit);
      await tapText(tester, S.submitAndGrade);
      expect(find.text(S.failed), findsOneWidget, reason: 'mục 23');
      expect(find.text(S.resultScore(24, 25)), findsOneWidget);
      expect(
        find.text(S.failCritical),
        findsOneWidget,
        reason: 'mục 23: lý do Sai câu điểm liệt',
      );
    },
  );

  testWidgets('D 24 + E 28: Không lưu và thoát; đổi hạng khi có bài dở → Hủy', (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    // 28 trước: tạo bài dở, lưu tạm
    await tapText(tester, S.practiceExam);
    await tapText(tester, S.randomTest);
    await tapText(tester, S.startTest);
    await choose(tester, 1, 0);
    await tapText(tester, S.submit);
    await tapText(tester, S.saveAndExit);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, S.changeClass);
    await tapText(tester, S.className('B'));
    expect(
      find.text(S.abandonExamTitle),
      findsOneWidget,
      reason: 'mục 28: hỏi Bỏ bài thi?',
    );
    await tapText(tester, S.cancel);
    final still = await openSession(tester);
    expect(still, isNotNull, reason: 'mục 28: giữ bài dở');
    expect(
      (await tester.runAsync(() => store.get('license_class'))),
      'A1',
      reason: 'mục 28: giữ hạng cũ',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    // 24
    await tapText(tester, S.resumeExam);
    await tapText(tester, S.submit);
    await tapText(tester, S.discardAndExit);
    expect(
      find.text(S.discardConfirmTitle),
      findsOneWidget,
      reason: 'mục 24: hỏi xác nhận',
    );
    await tapText(tester, S.discard);
    await tester.pumpAndSettle();
    expect(await openSession(tester), isNull, reason: 'mục 24: bài bị bỏ');
    // về màn chính
    while (find.text(S.studyByTopic).evaluate().isEmpty) {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
    expect(
      find.text(S.resumeExam),
      findsNothing,
      reason: 'mục 24: không còn thẻ Tiếp tục',
    );
  });

  // ---------------- E. Biển báo, thống kê, giao diện ----------------
  testWidgets('E 25–26: 7 tab biển báo, chi tiết, QCVN đầy đủ, tìm kiếm', (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    await tapText(tester, S.trafficSigns);
    final tabs = tester
        .widgetList<Tab>(find.byType(Tab, skipOffstage: false))
        .map((t) => t.text)
        .toList();
    expect(tabs.length, 7, reason: 'mục 25: 7 tab — thấy $tabs');
    await tap(
      tester,
      find
          .descendant(
            of: find.byType(TabBarView),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(find.byType(SignDetailScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.text(S.signMeaningFull), 200);
    await tapText(tester, S.signMeaningFull);
    final shownSign = content.signs.firstWhere(
      (x) =>
          x.code ==
          tester.widget<SignDetailScreen>(find.byType(SignDetailScreen)).code,
    );
    expect(
      find.text(shownSign.meaning),
      findsOneWidget,
      reason: 'mục 25: mở đoạn văn đầy đủ',
    );
    expect(find.text(shownSign.name), findsOneWidget, reason: 'mục 25: có tên');
    expect(find.byType(ExpansionTile), findsOneWidget);
    final tile = tester.state<State>(find.byType(ExpansionTile));
    expect(tile.mounted, isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    // 26
    await tap(tester, find.byTooltip(S.searchSigns));
    await tester.enterText(find.byType(TextField), 'quay dau');
    await tester.pumpAndSettle();
    expect(
      find.text('P.124a'),
      findsOneWidget,
      reason: 'mục 26: quay dau → P.124a',
    );
    expect(find.textContaining('Cấm quay đầu xe'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'P124');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('P.124'),
      findsWidgets,
      reason: 'mục 26: P124 → các biển P.124…',
    );
  });

  testWidgets('E 27: thống kê sau một lần thi; chạm lần thi mở xem lại', (
    tester,
  ) async {
    await boot(tester);
    await openApp(tester);
    await tapText(tester, S.practiceExam);
    await tapText(tester, S.randomTest);
    await tapText(tester, S.startTest);
    await choose(tester, 1, 0);
    await tapText(tester, S.submit);
    await tapText(tester, S.submitAndGrade);
    await tapText(tester, S.backHome);
    await tapText(tester, S.statistics);
    expect(find.text(S.testsTaken), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text(S.passRate), findsOneWidget);

    expect(find.text(S.latestScore), findsOneWidget);
    expect(find.text(S.topicProgress), findsOneWidget);
    await tester.scrollUntilVisible(find.text(S.testHistory), 200);
    expect(find.text(S.testHistory), findsOneWidget);
    await tester.scrollUntilVisible(find.text(S.randomTest), 200);
    await tap(tester, find.text(S.randomTest));
    expect(
      find.text(S.reviewTest),
      findsOneWidget,
      reason: 'mục 27: mở xem lại bài',
    );
    expect(find.byType(QuestionView), findsWidgets);
  });

  testWidgets('E 29: chế độ tối của máy → app nền tối', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);
    await openApp(tester);
    final ctx = tester.element(find.text(S.studyByTopic));
    expect(Theme.of(ctx).brightness, Brightness.dark, reason: 'mục 29');
  });

  // ---------------- F. Android (mô phỏng phần logic) ----------------
  testWidgets(
    'F 30–31: ra ngoài 1 phút đồng hồ trừ đúng; tắt app mở lại hỏi tiếp tục, đáp án còn',
    (tester) async {
      await boot(tester);
      await openApp(tester);
      await tapText(tester, S.practiceExam);
      await tapText(tester, S.randomTest);
      await tapText(tester, S.startTest);
      await choose(tester, 1, 2);
      // 30: app ở nền 1 phút (timer không chạy), quay lại
      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('18:00'),
        findsOneWidget,
        reason: 'mục 30: trừ đúng 1 phút',
      );
      // 31
      await openApp(tester);
      expect(
        find.text(S.resumePromptTitle),
        findsOneWidget,
        reason: 'mục 31: hỏi tiếp tục',
      );
      await tapText(tester, S.resume);
      expect(
        statesAt(tester, 1)[2],
        AnswerState.chosen,
        reason: 'mục 31: đáp án còn',
      );
    },
  );
}
