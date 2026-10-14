import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 14, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final topics = buildTopics(
    pool: questionPool(content.questions, 'A1', pool: a1.pool),
    licenseClass: 'A1',
  );
  final critical = topics[1].questions; // 20 questions
  int wrongOf(Question q) => q.correctIndex == 0 ? 1 : 0;

  late AppDatabase db;

  Future<void> openApp(WidgetTester tester) async {
    db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(content: content, db: db, store: onboarded('A1'), now: now),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  Future<void> openCriticalTopic(WidgetTester tester) async {
    await tapText(tester, S.studyByTopic);
    await tapText(tester, S.topicCritical);
  }

  /// Taps an option of the question currently on screen (other pages may share option texts).
  Future<void> answer(WidgetTester tester, int position, int option) async {
    final view = find.byWidgetPredicate(
      (w) => w is QuestionView && w.position == position,
    );
    final q = tester.widget<QuestionView>(view).question;
    final target = find.descendant(
      of: view,
      matching: find.text(q.options[option]),
    );
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byTooltip(S.nextQuestion));
    await tester.pumpAndSettle();
  }

  /// A number in the question grid (option badges also show 1–4).
  Finder gridCell(String n) => find.descendant(of: find.byType(BottomSheet), matching: find.text(n));

  ProgressRepository repo() => ProgressRepository(db.db, clock: () => now);

  testWidgets(
    'danh sách chủ đề: Tất cả, Điểm liệt, các chương, mỗi mục có Đúng/Sai/Chưa làm (AC1)',
    (tester) async {
      await openApp(tester);
      await tapText(tester, S.studyByTopic);
      expect(find.text(S.topicAll), findsOneWidget);
      expect(find.text(S.topicCritical), findsOneWidget);
      final firstChapter = topics[2].chapter!;
      expect(
        find.text(
          S.chapterTitle(firstChapter, content.chapters[firstChapter]!),
        ),
        findsOneWidget,
      );
      expect(find.text(S.topicStats(0, 0, 250)), findsOneWidget);
      expect(find.text(S.topicStats(0, 0, 20)), findsOneWidget);
    },
  );

  testWidgets(
    'trả lời sai → vào "Câu sai", danh sách chủ đề và màn chính cập nhật (AC3)',
    (tester) async {
      await openApp(tester);
      await openCriticalTopic(tester);
      await answer(tester, 1, wrongOf(critical[0]));
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(await tester.runAsync(() => repo().wrongList()), {critical[0].id});

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(S.topicStats(0, 1, 19)), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(S.questionCount(1)), findsOneWidget); // home: Ôn câu sai
    },
  );

  testWidgets(
    'chuyển câu, nhảy qua lưới; thoát và vào lại mở câu đang dở, đáp án cũ vẫn hiện (AC2)',
    (tester) async {
      await openApp(tester);
      await openCriticalTopic(tester);
      await answer(tester, 1, critical[0].correctIndex);
      await next(tester);
      expect(find.text(S.questionOfTotal(2, 20)), findsOneWidget);

      await tester.tap(find.text(S.questionOfTotal(2, 20)));
      await tester.pumpAndSettle();
      await tester.tap(gridCell('15'));
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(15, 20)), findsOneWidget);
      expect(find.text(critical[14].content), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapText(tester, S.topicCritical);
      expect(find.text(S.questionOfTotal(15, 20)), findsOneWidget);

      await tester.tap(find.byTooltip(S.previousQuestion));
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(14, 20)), findsOneWidget);

      await tester.tap(find.text(S.questionOfTotal(14, 20)));
      await tester.pumpAndSettle();
      await tester.tap(gridCell('1'));
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.check),
        findsOneWidget,
        reason: 'câu 1 đã làm đúng, vẫn hiện và khóa',
      );
    },
  );

  testWidgets(
    'làm hết chủ đề → tóm tắt đúng/sai, "Ôn câu sai của chủ đề" mở các câu sai (AC4)',
    (tester) async {
      await openApp(tester);
      await openCriticalTopic(tester);
      for (var i = 0; i < critical.length; i++) {
        final wrong = i < 3;
        await answer(
          tester,
          i + 1,
          wrong ? wrongOf(critical[i]) : critical[i].correctIndex,
        );
        if (i < critical.length - 1) await next(tester);
      }
      expect(find.text(S.topicFinished), findsOneWidget);
      expect(find.text(S.roundResult(17, 3, 20)), findsOneWidget);

      await tester.tap(find.text(S.reviewTopicWrong));
      await tester.pumpAndSettle();
      expect(find.text(S.wrongOfTopic(S.topicCritical)), findsOneWidget);
      expect(find.text(S.questionOfTotal(1, 3)), findsOneWidget);
      expect(
        find.byIcon(Icons.check),
        findsNothing,
        reason: 'ôn câu sai bắt đầu trống',
      );
    },
  );

  testWidgets(
    '"Làm lại" xóa đáp án đang hiện của chủ đề, giữ danh sách câu sai',
    (tester) async {
      await openApp(tester);
      await openCriticalTopic(tester);
      await answer(tester, 1, wrongOf(critical[0]));
      await tester.tap(find.byTooltip(S.restartTopic));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, S.restartTopic));
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(1, 20)), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(await tester.runAsync(() => repo().wrongList()), {critical[0].id});
    },
  );
}
