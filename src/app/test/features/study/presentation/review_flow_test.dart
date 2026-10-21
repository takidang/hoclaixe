import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 14, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final q = questionPool(content.questions, 'A1', pool: a1.pool)[10];

  late AppDatabase db;

  Future<void> openApp(
    WidgetTester tester, {
    String cls = 'A1',
    bool withWrong = false,
  }) async {
    db = await openTestDatabase(tester);
    if (withWrong) {
      await tester.runAsync(
        () =>
            ProgressRepository(
              db.db,
              clock: () => now.subtract(const Duration(days: 1)),
            ).recordAnswer(
              questionId: q.id,
              mode: AnswerMode.study,
              selectedIndex: q.correctIndex == 0 ? 1 : 0,
              isCorrect: false,
            ),
      );
    }
    await tester.pumpWidget(
      testApp(content: content, db: db, store: onboarded(cls), now: now),
    );
    await tester.pumpAndSettle();
  }

  /// Home tiles sit below the fold on the 800×600 test screen.
  Future<void> tapTile(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<Set<String>> wrongList(WidgetTester tester) async =>
      (await tester.runAsync(() => ProgressRepository(db.db).wrongList()))!;

  Future<void> answerCorrectly(WidgetTester tester) async {
    final view = find.byType(QuestionView);
    final shown = tester.widget<QuestionView>(view).question;
    final target = find.descendant(
      of: view,
      matching: find.text(shown.options[shown.correctIndex]),
    );
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'ôn câu sai theo chế độ học; đúng 2 lần liên tiếp mới ra khỏi danh sách (AC1)',
    (tester) async {
      await openApp(tester, withWrong: true);
      await tapTile(tester, S.reviewWrong);
      expect(find.text(S.wrongOfTopic(S.topicAll)), findsOneWidget);
      expect(find.text(S.questionOfTotal(1, 1)), findsOneWidget);

      await answerCorrectly(tester);
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(find.text(S.topicFinished), findsOneWidget);
      expect(await wrongList(tester), {q.id}, reason: 'mới đúng 1 lần');

      await tester.tap(find.text(S.reviewRemainingWrong));
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(1, 1)), findsOneWidget);
      await answerCorrectly(tester);
      expect(await wrongList(tester), isEmpty, reason: 'đúng 2 lần liên tiếp');

      await tester.tap(find.text(S.reviewRemainingWrong));
      await tester.pumpAndSettle();
      expect(find.text(S.noWrongYet), findsOneWidget);
    },
  );

  testWidgets('chưa có câu sai → "Bạn chưa có câu sai" và nút Thi thử (AC2)', (
    tester,
  ) async {
    await openApp(tester);
    await tapTile(tester, S.reviewWrong);
    expect(find.text(S.noWrongYet), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, S.practiceExam));
    await tester.pumpAndSettle();
    expect(find.text(S.randomTest), findsOneWidget); // exam list (ST-11)
  });

  for (final (cls, count) in [('A1', 20), ('A', 20), ('B', 60)]) {
    testWidgets('hạng $cls: "Câu điểm liệt" có đúng $count câu (AC3)', (
      tester,
    ) async {
      await openApp(tester, cls: cls);
      await tapTile(tester, S.criticalQuestions);
      expect(find.text(S.questionOfTotal(1, count)), findsOneWidget);
    });
  }
}
