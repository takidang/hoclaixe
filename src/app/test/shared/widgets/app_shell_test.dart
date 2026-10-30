import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 30, 9);

  testWidgets(
    'thanh tab: 4 tab mở đúng màn, tab đang chọn được đánh dấu; mở lại tab Học vẫn ở chỗ cũ',
    (tester) async {
      final db = await openTestDatabase(tester);
      await tester.pumpWidget(
        testApp(content: content, db: db, store: onboarded('A1'), now: now),
      );
      await tester.pumpAndSettle();

      // the tab button's own Semantics (the screen title can carry the same words)
      void expectSelected(String tab, {required bool on}) => expect(
        tester
            .widget<Semantics>(
              find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.button == true &&
                    w.properties.label == tab,
              ),
            )
            .properties
            .selected,
        on,
        reason: tab,
      );
      expectSelected(S.tabOverview, on: true);

      for (final (tab, title) in [
        (S.studyByTopic, S.studyByTopic),
        (S.savedQuestions, S.savedQuestions),
        (S.statistics, S.statistics),
      ]) {
        await openTab(tester, tab);
        expect(find.widgetWithText(AppBar, title), findsOneWidget, reason: tab);
        expectSelected(tab, on: true);
        expectSelected(S.tabOverview, on: false);
      }

      // each tab keeps its own state: scroll the topic list, leave, come back
      await openTab(tester, S.studyByTopic);
      final list = find.byType(Scrollable).first;
      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      final offset = tester.state<ScrollableState>(list).position.pixels;
      expect(offset, greaterThan(0));
      await openTab(tester, S.tabOverview);
      await openTab(tester, S.studyByTopic);
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        offset,
      );
    },
  );

  testWidgets(
    'tab Thống kê: biểu đồ đếm câu học và câu thi thử 30 ngày qua, chuỗi ngày học',
    (tester) async {
      final db = await openTestDatabase(tester);
      await tester.runAsync(() async {
        // two answers yesterday, one today; a test answer is logged with mode exam
        for (final (at, mode) in [
          (now.subtract(const Duration(days: 1)), AnswerMode.study),
          (now.subtract(const Duration(days: 1)), AnswerMode.critical),
          (now, AnswerMode.exam),
        ]) {
          await ProgressRepository(db.db, clock: () => at).recordAnswer(
            questionId: content.questions.first.id,
            mode: mode,
            selectedIndex: 0,
            isCorrect: true,
          );
        }
      });
      await tester.pumpWidget(
        testApp(content: content, db: db, store: onboarded('A1'), now: now),
      );
      await tester.pumpAndSettle();
      await openTab(tester, S.statistics);

      expect(find.bySemanticsLabel(S.activitySummary(2, 1)), findsOneWidget);
      expect(find.text(S.days(2)), findsOneWidget, reason: 'hôm qua + hôm nay');
      expect(find.text(S.noActivity), findsNothing);
    },
  );
}
