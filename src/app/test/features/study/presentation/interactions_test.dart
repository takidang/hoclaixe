import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/core/theme/app_theme.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

/// "Tự chuyển câu", press-and-hold topic actions, swipe to unsave, button colours (30/10/2026).
void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 30, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final critical = buildTopics(
    pool: questionPool(content.questions, 'A1', pool: a1.pool),
    licenseClass: 'A1',
  )[1].questions;

  late AppDatabase db;
  late InMemorySettingsStore store;

  Future<void> open(WidgetTester tester, {bool autoNext = false}) async {
    db = await openTestDatabase(tester);
    store = InMemorySettingsStore({
      SettingKeys.disclaimerAccepted: '1',
      SettingKeys.licenseClass: 'A1',
      SettingKeys.themeMode: 'light',
      if (autoNext) SettingKeys.autoNext: '1',
    });
    await tester.pumpWidget(
      testApp(content: content, db: db, store: store, now: now),
    );
    await tester.pumpAndSettle();
  }

  /// Taps option [option] of the question at [position] on screen.
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
    await tester.pump();
  }

  int wrongOf(int correct) => correct == 0 ? 1 : 0;

  testWidgets(
    'tự chuyển câu (học): đúng → sang câu sau; sai → ở lại để xem đáp án',
    (tester) async {
      await open(tester, autoNext: true);
      await tapCard(tester, S.criticalQuestions);
      await answer(tester, 1, critical[0].correctIndex);
      await tester.pump(AppMotion.autoNextStudy);
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(2, 20)), findsOneWidget);

      await answer(tester, 2, wrongOf(critical[1].correctIndex));
      await tester.pump(AppMotion.autoNextStudy);
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(2, 20)), findsOneWidget);
    },
  );

  testWidgets('tắt tự chuyển câu (mặc định): trả lời đúng vẫn ở lại câu đó', (
    tester,
  ) async {
    await open(tester);
    await tapCard(tester, S.criticalQuestions);
    await answer(tester, 1, critical[0].correctIndex);
    await tester.pump(AppMotion.autoNextStudy);
    await tester.pumpAndSettle();
    expect(find.text(S.questionOfTotal(1, 20)), findsOneWidget);
  });

  testWidgets('tự chuyển câu (thi thử): chọn đáp án xong sang câu sau', (
    tester,
  ) async {
    await open(tester, autoNext: true);
    await tapCard(tester, S.practiceExam);
    await tapCard(tester, S.fixedTest(1));
    await tapCard(tester, S.startTest);
    expect(find.text(S.questionOfTotal(1, a1.questionCount)), findsOneWidget);
    await answer(tester, 1, 0);
    await tester.pump(AppMotion.autoNextExam);
    await tester.pumpAndSettle();
    expect(find.text(S.questionOfTotal(2, a1.questionCount)), findsOneWidget);
  });

  testWidgets(
    'đang thi: bật/tắt tự chuyển câu ngay trên thanh tiêu đề, có tác dụng liền',
    (tester) async {
      await open(tester);
      await tapCard(tester, S.practiceExam);
      await tapCard(tester, S.fixedTest(1));
      await tapCard(tester, S.startTest);

      await tester.tap(find.byTooltip(S.autoNextIsOff));
      await tester.pumpAndSettle();
      expect(find.text(S.autoNextTurnedOn), findsOneWidget);
      expect(find.byTooltip(S.autoNextIsOn), findsOneWidget);
      expect(await store.get(SettingKeys.autoNext), '1');

      await answer(tester, 1, 0);
      await tester.pump(AppMotion.autoNextExam);
      await tester.pumpAndSettle();
      expect(find.text(S.questionOfTotal(2, a1.questionCount)), findsOneWidget);

      await tester.tap(find.byTooltip(S.autoNextIsOn));
      await tester.pumpAndSettle();
      await answer(tester, 2, 0);
      await tester.pump(AppMotion.autoNextExam);
      await tester.pumpAndSettle();
      expect(
        find.text(S.questionOfTotal(2, a1.questionCount)),
        findsOneWidget,
        reason: 'đã tắt: ở lại câu 2',
      );
    },
  );

  testWidgets('Giới thiệu: bật "Tự chuyển câu" thì lưu lại', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip(S.about));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.autoNext));
    await tester.pumpAndSettle();
    expect(await store.get(SettingKeys.autoNext), '1');
  });

  testWidgets(
    'nhấn giữ thẻ chủ đề → thao tác nhanh; "Làm lại từ đầu" xóa đáp án đang hiện',
    (tester) async {
      await open(tester);
      await openTab(tester, S.studyByTopic);
      await tapCard(tester, S.topicCritical);
      await answer(tester, 1, critical[0].correctIndex);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget, reason: 'đã trả lời');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.longPress(find.text(S.topicCritical));
      await tester.pumpAndSettle();
      expect(find.text(S.continueStudy), findsOneWidget);
      expect(find.text(S.restartFromStart), findsOneWidget);
      await tester.tap(find.text(S.restartFromStart));
      await tester.pumpAndSettle();

      expect(find.text(S.questionOfTotal(1, 20)), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing, reason: 'lượt mới');
    },
  );

  testWidgets('vuốt câu đã lưu sang trái → bỏ lưu; "Hoàn tác" lưu lại', (
    tester,
  ) async {
    await open(tester);
    await tester.runAsync(
      () => ProgressRepository(db.db).setSaved(critical[0].id, saved: true),
    );
    await openTab(tester, S.savedQuestions);
    expect(find.text(critical[0].content), findsOneWidget);

    await tester.drag(find.text(critical[0].content), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text(critical[0].content), findsNothing);
    expect(find.text(S.unsaved), findsOneWidget);
    expect(
      await tester.runAsync(() => ProgressRepository(db.db).savedIds()),
      isEmpty,
    );

    await tester.tap(find.text(S.undo));
    await tester.pumpAndSettle();
    expect(find.text(critical[0].content), findsOneWidget);
    expect(await tester.runAsync(() => ProgressRepository(db.db).savedIds()), [
      critical[0].id,
    ]);
  });

  test(
    'nút chính: viên thuốc màu thanh tab (đen ở nền sáng, trắng ở nền tối)',
    () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final style = theme.filledButtonTheme.style!;
        expect(
          style.backgroundColor!.resolve({}),
          theme.colorScheme.inverseSurface,
        );
        expect(style.shape!.resolve({}), isA<StadiumBorder>());
      }
    },
  );
}
