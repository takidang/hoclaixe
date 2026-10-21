import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

/// ST-13 AC2 / NFR-07: on a 360×780 phone with system text at 130 %, every main screen lays out without
/// overflow (an overflow is reported as an exception and fails the test), and tappable targets are ≥ 48dp.
void main() {
  final content = loadRealContent();

  Future<void> phone(WidgetTester tester, InMemorySettingsStore store) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: store,
        now: DateTime(2026, 10, 21, 9),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('cỡ chữ 130%: miễn trừ, chọn hạng không tràn', (tester) async {
    await phone(tester, InMemorySettingsStore());
    expect(find.text(S.disclaimerTitle), findsOneWidget);
    await tap(tester, find.text(S.disclaimerAccept));
    expect(find.text(S.chooseClassTitle), findsOneWidget);
  });

  testWidgets('cỡ chữ 130%: màn chính, học, biển báo không tràn', (
    tester,
  ) async {
    await phone(tester, onboarded('B'));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tap(tester, find.text(S.studyByTopic));
    await tap(tester, find.text(S.topicCritical));
    final view = find.byType(QuestionView);
    final q = tester.widget<QuestionView>(view).question;
    await tap(
      tester,
      find.descendant(of: view, matching: find.text(q.options.first)),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap(tester, find.text(S.trafficSigns));
    await tap(tester, find.text(content.signs.first.code));
    expect(
      find.widgetWithText(AppBar, content.signs.first.code),
      findsOneWidget,
    );
  });

  testWidgets(
    'cỡ chữ 130%: thi thử từ chọn đề tới kết quả không tràn; vùng chạm màn thi ≥ 48dp',
    (tester) async {
      await phone(tester, onboarded('A1'));
      await tap(tester, find.text(S.practiceExam));
      await tap(tester, find.text(S.fixedTest(1)));
      await tap(tester, find.text(S.startTest));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await tap(tester, find.text(S.submit));
      await tap(tester, find.text(S.submitAndGrade));
      expect(find.text(S.failed), findsOneWidget);
      // with 130 % text the button sits below the built part of the result list
      await tester.scrollUntilVisible(find.text(S.reviewTest), 200, scrollable: find.byType(Scrollable).first);
      await tap(tester, find.text(S.reviewTest));
      expect(find.byType(QuestionView), findsWidgets);
    },
  );
}
