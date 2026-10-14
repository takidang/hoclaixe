import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/core/theme/app_theme.dart';
import 'package:hoclaixe/shared/widgets/image_zoom_page.dart';
import 'package:hoclaixe/shared/widgets/question_view.dart';

import '../../support/real_content.dart';

void main() {
  final questions = loadRealContent().questions;
  final withImage = questions.firstWhere(
    (q) => q.images.isNotEmpty && !q.isCriticalFor('A1'),
  );
  final critical = questions.firstWhere((q) => q.isCriticalFor('A1'));
  int wrongIndexOf(Question q) => q.correctIndex == 0 ? 1 : 0;

  /// Hosts the view the way a screen would: keeps the selection, records every onSelect call.
  Future<List<int>> show(
    WidgetTester tester,
    Question q,
    QuestionMode mode, {
    int? selected,
  }) async {
    final calls = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => QuestionView(
                question: q,
                position: 5,
                licenseClass: 'A1',
                mode: mode,
                selectedIndex: selected,
                onSelect: (i) => setState(() {
                  calls.add(i);
                  selected = i;
                }),
              ),
            ),
          ),
        ),
      ),
    );
    // Images decode only with real async; load them before measuring and tapping.
    final context = tester.element(find.byType(QuestionView));
    await tester.runAsync(() async {
      for (final asset in q.images) {
        await precacheImage(AssetImage(asset), context);
      }
    });
    await tester.pumpAndSettle();
    return calls;
  }

  /// Scrolls the option into view first (the test screen is 800×600).
  Future<void> tapOption(WidgetTester tester, Question q, int i) async {
    await tester.ensureVisible(find.text(q.options[i]));
    await tester.pumpAndSettle();
    await tester.tap(find.text(q.options[i]));
    await tester.pumpAndSettle();
  }

  Finder option(Question q, int i) => find.text(q.options[i]);

  group('chế độ học (AC2)', () {
    testWidgets(
      'chọn sai → hiện ✗ ở đáp án đã chọn, ✓ ở đáp án đúng, rồi khóa câu',
      (tester) async {
        final calls = await show(tester, withImage, QuestionMode.study);
        expect(find.byIcon(Icons.check), findsNothing);

        await tapOption(tester, withImage, wrongIndexOf(withImage));
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        await tapOption(tester, withImage, withImage.correctIndex);
        expect(calls, [
          wrongIndexOf(withImage),
        ], reason: 'câu đã khóa, chỉ lần chọn đầu được ghi nhận');
      },
    );

    testWidgets('chọn đúng → chỉ có ✓', (tester) async {
      await show(tester, withImage, QuestionMode.study);
      await tapOption(tester, withImage, withImage.correctIndex);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('câu điểm liệt của hạng có nhãn "Điểm liệt"', (tester) async {
      await show(tester, critical, QuestionMode.study);
      expect(find.text(S.criticalBadge), findsOneWidget);
    });

    testWidgets('câu không phải điểm liệt thì không có nhãn', (tester) async {
      await show(tester, withImage, QuestionMode.study);
      expect(find.text(S.criticalBadge), findsNothing);
    });
  });

  group('chế độ thi (AC3)', () {
    testWidgets('đổi được đáp án, không hiện đúng/sai', (tester) async {
      final calls = await show(tester, withImage, QuestionMode.exam);
      await tapOption(tester, withImage, 0);
      await tapOption(tester, withImage, 1);
      expect(calls, [0, 1]);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(tester.getSemantics(option(withImage, 1)).label, endsWith(S.answerChosen));
    });

    testWidgets(
      'không hiện nhãn "Điểm liệt" kể cả với câu điểm liệt (FR-A22)',
      (tester) async {
        await show(tester, critical, QuestionMode.exam);
        expect(find.text(S.criticalBadge), findsNothing);
      },
    );
  });

  group('xem lại bài', () {
    testWidgets(
      'câu bỏ trống: ghi "Chưa trả lời", hiện đáp án đúng, có nhãn điểm liệt',
      (tester) async {
        final calls = await show(tester, critical, QuestionMode.review);
        expect(find.text(S.notAnswered), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.text(S.criticalBadge), findsOneWidget);
        await tapOption(tester, critical, 0);
        expect(calls, isEmpty, reason: 'chỉ xem, không chọn được');
      },
    );

    testWidgets('câu đã trả lời sai: ✗ và ✓, không ghi "Chưa trả lời"', (
      tester,
    ) async {
      await show(
        tester,
        withImage,
        QuestionMode.review,
        selected: wrongIndexOf(withImage),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text(S.notAnswered), findsNothing);
    });
  });

  testWidgets('hiện thứ tự câu và số gốc trong bộ 600 câu (AC4, Q8)', (
    tester,
  ) async {
    await show(tester, withImage, QuestionMode.study);
    expect(find.text(S.questionNumber(5)), findsOneWidget);
    expect(find.text(S.officialNumber(withImage.number)), findsOneWidget);
  });

  group('phóng to hình (AC1)', () {
    Future<void> doubleTap(WidgetTester tester, Finder f) async {
      await tester.tap(f);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'chạm hình → màn xem lớn, phóng tới ≥ 3 lần; chạm đúp khi chưa phóng → quay lại câu hỏi',
      (tester) async {
        await show(tester, withImage, QuestionMode.study);
        await tester.ensureVisible(find.bySemanticsLabel(S.zoomImage));
      await tester.tap(find.bySemanticsLabel(S.zoomImage));
        await tester.pumpAndSettle();
        expect(find.byType(ImageZoomPage), findsOneWidget);
        expect(
          tester
              .widget<InteractiveViewer>(find.byType(InteractiveViewer))
              .maxScale,
          greaterThanOrEqualTo(3),
        );

        await doubleTap(tester, find.byType(InteractiveViewer));
        expect(find.byType(ImageZoomPage), findsNothing);
        expect(find.text(withImage.content), findsOneWidget);
      },
    );

    testWidgets('đang phóng to → chạm đúp trở về cỡ ban đầu', (tester) async {
      await show(tester, withImage, QuestionMode.study);
      await tester.ensureVisible(find.bySemanticsLabel(S.zoomImage));
      await tester.tap(find.bySemanticsLabel(S.zoomImage));
      await tester.pumpAndSettle();
      final controller = tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!;
      controller.value = Matrix4.diagonal3Values(3, 3, 1);

      await doubleTap(tester, find.byType(InteractiveViewer));
      expect(find.byType(ImageZoomPage), findsOneWidget);
      expect(controller.value.getMaxScaleOnAxis(), 1);
    });

    testWidgets('nút Đóng quay lại câu hỏi', (tester) async {
      await show(tester, withImage, QuestionMode.study);
      await tester.ensureVisible(find.bySemanticsLabel(S.zoomImage));
      await tester.tap(find.bySemanticsLabel(S.zoomImage));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(S.close));
      await tester.pumpAndSettle();
      expect(find.byType(ImageZoomPage), findsNothing);
    });
  });
}
