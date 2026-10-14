import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
import 'package:hoclaixe/features/exam/domain/exam_generator.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 14, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final a1Pool = questionPool(content.questions, 'A1', pool: a1.pool);

  late AppDatabase db;
  late InMemorySettingsStore store;

  Future<void> setUpDb(
    WidgetTester tester, {
    String licenseClass = 'A1',
  }) async {
    db = await openTestDatabase(tester);
    store = onboarded(licenseClass);
  }

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(content: content, db: db, store: store, now: now),
    );
    await tester.pumpAndSettle();
  }

  ExamSessionRepository sessions() =>
      ExamSessionRepository(db.db, clock: () => now);

  Future<void> startA1Exam(WidgetTester tester) => tester.runAsync(
    () => sessions().start(
      const ExamGenerator().generate(
        structure: a1,
        bank: content.questions,
        random: Random(1),
      ),
      a1,
    ),
  );

  testWidgets(
    'hiện hạng, tiến độ tổng và 5 ô chức năng; số câu sai và điểm liệt theo hạng (AC1)',
    (tester) async {
      await setUpDb(tester);
      final progress = ProgressRepository(db.db, clock: () => now);
      await tester.runAsync(() async {
        for (final q in a1Pool.take(3)) {
          await progress.recordAnswer(
            questionId: q.id,
            mode: AnswerMode.study,
            selectedIndex: 0,
            isCorrect: true,
          );
        }
        await progress.recordAnswer(
          questionId: a1Pool[3].id,
          mode: AnswerMode.study,
          selectedIndex: 0,
          isCorrect: false,
        );
      });
      await start(tester);

      expect(homeTitle(S.className('A1')), findsOneWidget);
      expect(find.text(S.progressCount(3, a1Pool.length)), findsOneWidget);
      for (final label in [
        S.studyByTopic,
        S.practiceExam,
        S.reviewWrong,
        S.criticalQuestions,
        S.trafficSigns,
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text(S.questionCount(1)), findsOneWidget); // wrong list
      final critical = a1Pool.where((q) => q.isCriticalFor('A1')).length;
      expect(find.text(S.questionCount(critical)), findsOneWidget);
      expect(find.text(S.resumeExam), findsNothing);
    },
  );

  testWidgets('bấm ô chức năng mở màn tương ứng', (tester) async {
    await setUpDb(tester);
    await start(tester);
    await tester.tap(find.text(S.studyByTopic));
    await tester.pumpAndSettle();
    expect(find.text(S.comingSoon), findsOneWidget);
  });

  testWidgets(
    'có bài thi dở → thẻ "Tiếp tục bài thi" với thời gian còn lại (AC3)',
    (tester) async {
      await setUpDb(tester);
      await startA1Exam(tester);
      await start(tester);
      expect(find.text(S.resumeExam), findsOneWidget);
      expect(
        find.text(S.timeLeft(Duration(minutes: a1.durationMinutes))),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'đổi hạng khi không có bài dở: không hỏi, màn chính cập nhật (AC2)',
    (tester) async {
      await setUpDb(tester);
      await start(tester);
      await tester.tap(find.text(S.changeClass));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.className('B')));
      await tester.pumpAndSettle();
      expect(find.text(S.abandonExamTitle), findsNothing);
      expect(homeTitle(S.className('B')), findsOneWidget);
      expect(await store.get(SettingKeys.licenseClass), 'B');
    },
  );

  testWidgets('đổi hạng khi có bài dở: Hủy → giữ hạng cũ và bài dở (AC2)', (
    tester,
  ) async {
    await setUpDb(tester);
    await startA1Exam(tester);
    await start(tester);
    await tester.tap(find.text(S.changeClass));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.className('B')));
    await tester.pumpAndSettle();
    expect(find.text(S.abandonExamTitle), findsOneWidget);

    await tester.tap(find.text(S.cancel));
    await tester.pumpAndSettle();
    expect(await store.get(SettingKeys.licenseClass), 'A1');
    expect(await tester.runAsync(() => sessions().openSession()), isNotNull);
  });

  testWidgets('đổi hạng khi có bài dở: Bỏ → xóa bài dở, đổi hạng (AC2)', (
    tester,
  ) async {
    await setUpDb(tester);
    await startA1Exam(tester);
    await start(tester);
    await tester.tap(find.text(S.changeClass));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.className('B')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.abandonExam));
    await tester.pumpAndSettle();

    expect(homeTitle(S.className('B')), findsOneWidget);
    expect(find.text(S.resumeExam), findsNothing);
    expect(await tester.runAsync(() => sessions().openSession()), isNull);
  });

  testWidgets('chọn lại đúng hạng của bài dở thì không hỏi', (tester) async {
    await setUpDb(tester);
    await startA1Exam(tester);
    await start(tester);
    await tester.tap(find.text(S.changeClass));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.className('A1')));
    await tester.pumpAndSettle();
    expect(find.text(S.abandonExamTitle), findsNothing);
    expect(find.text(S.resumeExam), findsOneWidget);
  });
}
