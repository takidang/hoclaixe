import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/features/study/domain/study_topic.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

/// "Câu đã lưu", "Tìm câu hỏi", "Đọc câu hỏi" (30/10/2026).
void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 30, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', now)!.structure;
  final topics = buildTopics(
    pool: questionPool(content.questions, 'A1', pool: a1.pool),
    licenseClass: 'A1',
  );
  final critical = topics[1].questions;

  late AppDatabase db;

  Future<void> openApp(
    WidgetTester tester, {
    FakeQuestionReader? reader,
  }) async {
    db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: onboarded('A1'),
        now: now,
        reader: reader,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapTooltip(WidgetTester tester, String tip) async {
    await tester.tap(find.byTooltip(tip));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'lưu câu khi học → màn chính đếm 1 câu, "Câu đã lưu" mở đúng câu đó; bỏ lưu thì danh sách trống',
    (tester) async {
      await openApp(tester);
      expect(find.text(S.questionCount(0)), findsOneWidget);
      await tapText(tester, S.criticalQuestions);
      await tapTooltip(tester, S.saveQuestion);
      expect(find.text(S.savedToast), findsOneWidget);
      expect(find.byTooltip(S.unsaveQuestion), findsOneWidget);
      final ids = await tester.runAsync(
        () => ProgressRepository(db.db).savedIds(),
      );
      expect(ids, [critical[0].id], reason: 'lưu vào SQLite');

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(S.questionCount(1)), findsOneWidget);

      await tapText(tester, S.savedQuestions);
      final view = tester.widget<QuestionView>(find.byType(QuestionView));
      expect(view.question, critical[0]);

      await tapTooltip(tester, S.unsaveQuestion);
      expect(find.text(S.unsavedToast), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapText(tester, S.savedQuestions);
      expect(find.textContaining(S.noSavedYet), findsOneWidget);
    },
  );

  testWidgets(
    'tìm câu: gõ số gốc → bấm kết quả mở đúng câu để trả lời; chuỗi lạ → "Không tìm thấy"',
    (tester) async {
      await openApp(tester);
      await tapTooltip(tester, S.searchQuestions);
      expect(find.text(S.searchQuestionsEmpty), findsOneWidget);

      final target = critical[3];
      await tester.enterText(find.byType(TextField), '${target.number}');
      await tester.pumpAndSettle();
      await tester.tap(find.text(target.content).first);
      await tester.pumpAndSettle();
      final view = tester.widget<QuestionView>(find.byType(QuestionView));
      expect(view.question, target);
      expect(view.mode, QuestionMode.study);
      expect(
        find.widgetWithText(AppBar, S.officialNumber(target.number)),
        findsOneWidget,
        reason: 'tiêu đề theo số gốc, không lẫn với "Câu 1" trong thân',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzzzqqq');
      await tester.pumpAndSettle();
      expect(find.text(S.noQuestionFound), findsOneWidget);
    },
  );

  testWidgets(
    'đọc câu hỏi: đọc câu và các đáp án, nút thành "Dừng đọc"; đọc xong nút trở lại',
    (tester) async {
      final reader = FakeQuestionReader();
      await openApp(tester, reader: reader);
      await tapText(tester, S.criticalQuestions);
      await tapTooltip(tester, S.readQuestion);
      final q = critical[0];
      expect(reader.spoken.single, contains(q.content));
      expect(
        reader.spoken.single,
        contains('${S.answerLabel(1)}. ${q.options[0]}'),
      );
      expect(find.byTooltip(S.stopReading), findsOneWidget);

      reader.finish();
      await tester.pumpAndSettle();
      expect(find.byTooltip(S.readQuestion), findsOneWidget);

      await tapTooltip(tester, S.readQuestion);
      await tapTooltip(tester, S.stopReading);
      expect(reader.speaking, isFalse);
      expect(find.byTooltip(S.readQuestion), findsOneWidget);
    },
  );

  testWidgets('máy không có giọng tiếng Việt → báo cách cài, không lỗi', (
    tester,
  ) async {
    await openApp(tester, reader: FakeQuestionReader(voice: false));
    await tapText(tester, S.criticalQuestions);
    await tapTooltip(tester, S.readQuestion);
    expect(find.text(S.noVietnameseVoice), findsOneWidget);
    expect(find.byTooltip(S.readQuestion), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
