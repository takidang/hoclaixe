// Phone-size screenshots of real screens with the real fonts — for design review and the report.
// Not part of the normal test run. Generate with:
//   flutter test --update-goldens --dart-define=SCREENSHOTS=true test/screenshots
// Output: test/screenshots/out/*.png
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/question_pool.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/features/study/data/progress_repository.dart';
import 'package:hoclaixe/main.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../support/real_content.dart';
import '../support/test_app.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');

Future<void> _loadFonts() async {
  final family = FontLoader('BeVietnamPro');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    family.addFont(rootBundle.load('assets/fonts/BeVietnamPro-$w.ttf'));
  }
  await family.load();
  final mono = FontLoader('JetBrainsMono')
    ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Medium.ttf'));
  await mono.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

void main() {
  final content = loadRealContent();
  final start = DateTime(2026, 10, 21, 9);
  final a1 = StructurePicker.pick(content.structures, 'A1', start)!.structure;
  final pool = questionPool(content.questions, 'A1', pool: a1.pool);

  late AppDatabase db;
  late DateTime now;

  setUpAll(() async {
    if (_enabled) await _loadFonts();
  });

  Future<void> phone(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.platformBrightnessTestValue = dark
        ? Brightness.dark
        : Brightness.light;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    db = await openTestDatabase(tester);
    now = start;
    // some progress so the home screen is not empty
    await tester.runAsync(() async {
      for (var i = 100; i < 187; i++) {
        final q = pool[i]; // leaves the first questions of each topic unanswered for the study shot
        final wrong = i % 12 == 5;
        // spread over the last days, some in tests, so the activity chart has something to show
        final repo = ProgressRepository(
          db.db,
          clock: () => start.subtract(Duration(days: 1 + (i * 7) % 23)),
        );
        await repo.recordAnswer(
          questionId: q.id,
          mode: i % 5 == 0 ? AnswerMode.exam : AnswerMode.study,
          selectedIndex: wrong ? (q.correctIndex == 0 ? 1 : 0) : q.correctIndex,
          isCorrect: !wrong,
        );
      }
      final saved = ProgressRepository(db.db, clock: () => start);
      for (final i in [3, 40, 120]) {
        await saved.setSaved(pool[i].id, saved: true);
      }
    });
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: InMemorySettingsStore({
          SettingKeys.disclaimerAccepted: '1',
          SettingKeys.licenseClass: 'A1',
          SettingKeys.themeMode: dark ? 'dark' : 'light',
        }),
        now: start,
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Images decode only with real async: load the ones on screen before taking the picture.
  Future<void> loadImages(WidgetTester tester) async {
    final elements = find.byType(Image).evaluate().toList();
    await tester.runAsync(() async {
      for (final e in elements) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> shot(String name) =>
      expectLater(find.byType(HoclaixeApp), matchesGoldenFile('out/$name.png'));

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> pickOption(WidgetTester tester, {required bool correct}) async {
    final view = find.byType(QuestionView).first;
    final q = tester.widget<QuestionView>(view).question;
    final option = correct ? q.correctIndex : (q.correctIndex == 0 ? 1 : 0);
    await tap(
      tester,
      find.descendant(of: view, matching: find.text(q.options[option])),
    );
  }

  testWidgets('01 màn chính + 02 chế độ tối', (tester) async {
    await phone(tester);
    await loadImages(tester);
    await shot('01-home');
  }, skip: !_enabled);

  testWidgets('02 màn chính tối', (tester) async {
    await phone(tester, dark: true);
    await loadImages(tester);
    await shot('02-home-dark');
  }, skip: !_enabled);

  testWidgets('03 học: trả lời sai', (tester) async {
    await phone(tester);
    await tap(tester, find.text(S.criticalQuestions));
    await pickOption(tester, correct: false);
    await loadImages(tester);
    await shot('03-study-wrong');
  }, skip: !_enabled);

  testWidgets('04 chọn đề + 05 thông tin đề', (tester) async {
    await phone(tester);
    await tap(tester, find.text(S.practiceExam));
    await shot('04-exam-list');
    await tap(tester, find.text(S.fixedTest(1)));
    await shot('05-exam-info');
  }, skip: !_enabled);

  testWidgets('06 đang thi (còn 1:30) + 07 bảng thoát + 08 kết quả', (
    tester,
  ) async {
    await phone(tester);
    await tap(tester, find.text(S.practiceExam));
    await tap(tester, find.text(S.fixedTest(1)));
    await tap(tester, find.text(S.startTest));
    for (var i = 0; i < 6; i++) {
      await pickOption(tester, correct: i != 3);
      await tap(tester, find.byTooltip(S.nextQuestion));
    }
    now = now.add(
      Duration(minutes: a1.durationMinutes) - const Duration(seconds: 90),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await shot('06-exam');
    await tap(tester, find.text(S.submit));
    await shot('07-exit-sheet');
    await tap(tester, find.text(S.submitAndGrade));
    await shot('08-result');
  }, skip: !_enabled);

  testWidgets('09 biển báo + 10 chi tiết biển', (tester) async {
    await phone(tester);
    await tap(tester, find.text(S.trafficSigns));
    await loadImages(tester);
    await shot('09-signs');
    await tap(tester, find.byTooltip(S.searchSigns));
    await tester.enterText(find.byType(TextField), 'P.124a');
    await tester.pumpAndSettle();
    await tap(tester, find.widgetWithText(Card, 'P.124a'));
    await loadImages(tester);
    await shot('10-sign-detail');
  }, skip: !_enabled);

  testWidgets('11 thống kê', (tester) async {
    await phone(tester);
    await openTab(tester, S.statistics);
    await shot('11-stats');
  }, skip: !_enabled);

  testWidgets('13 tìm câu hỏi + 14 câu tìm được', (tester) async {
    await phone(tester);
    await tap(tester, find.byTooltip(S.searchQuestions));
    await tester.enterText(find.byType(TextField), 'nong do con');
    await tester.pumpAndSettle();
    await shot('13-search');
  }, skip: !_enabled);

  testWidgets('15 câu hỏi màn tối', (tester) async {
    await phone(tester, dark: true);
    await tap(tester, find.text(S.criticalQuestions));
    await pickOption(tester, correct: true);
    await loadImages(tester);
    await shot('15-study-dark');
  }, skip: !_enabled);

  testWidgets('16 tab Học + 17 tab Câu đã lưu + 18 tab Thống kê (tối)', (
    tester,
  ) async {
    await phone(tester, dark: true);
    await openTab(tester, S.studyByTopic);
    await shot('16-study-tab');
    await openTab(tester, S.savedQuestions);
    await shot('17-saved-tab');
    await openTab(tester, S.statistics);
    await shot('18-stats-dark');
  }, skip: !_enabled);

  testWidgets('12 giới thiệu (chọn giao diện)', (tester) async {
    await phone(tester);
    await tap(tester, find.byTooltip(S.about));
    await shot('12-about');
  }, skip: !_enabled);
}
