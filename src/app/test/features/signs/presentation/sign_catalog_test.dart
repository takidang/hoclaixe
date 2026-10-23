import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/strings.dart';

import '../../../support/real_content.dart';
import '../../../support/test_app.dart';

void main() {
  final content = loadRealContent();

  Future<void> openSigns(WidgetTester tester) async {
    final db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: onboarded('B'),
        now: DateTime(2026, 10, 21, 9),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(S.trafficSigns));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.trafficSigns));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tab theo đủ 7 nhóm trong signs.json; mỗi mục có mã và tên (ST-12 AC1)',
    (tester) async {
      await openSigns(tester);
      for (final name in content.signGroups.values) {
        expect(
          find.widgetWithText(Tab, name, skipOffstage: false),
          findsOneWidget,
          reason: name,
        );
      }
      final first = content.signs.firstWhere(
        (s) => s.group == content.signGroups.keys.first,
      );
      expect(find.text(first.code), findsOneWidget);
      expect(find.text(first.name), findsWidgets);
    },
  );

  testWidgets(
    'chạm một biển → chi tiết: hình, mã, tên, nhóm, mô tả ngắn, mở "Xem đầy đủ" (ST-12 AC2)',
    (tester) async {
      await openSigns(tester);
      final sign = content.signs.firstWhere(
        (s) => s.group == 'cam' && s.images.isNotEmpty,
      );
      await tester.tap(find.text(sign.code));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, sign.code), findsOneWidget);
      expect(find.text(sign.name), findsOneWidget);
      expect(find.text(sign.groupName), findsOneWidget);
      expect(find.text(sign.summary), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.text(sign.meaning), findsNothing);
      await tester.scrollUntilVisible(
        find.text(S.signMeaningFull),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(S.signMeaningFull));
      await tester.pumpAndSettle();
      expect(find.text(sign.meaning), findsOneWidget);
    },
  );

  testWidgets(
    'biển không có hình → khung thay thế + lý do, không lỗi (ST-12 AC3)',
    (tester) async {
      // every catalog entry has a picture now; strip one to keep the fallback covered
      final real = content.signs.first;
      final noImage = TrafficSign(
        code: real.code,
        name: real.name,
        group: real.group,
        groupName: real.groupName,
        summary: real.summary,
        meaning: real.meaning,
        images: const [],
        noImageReason: 'QCVN không có hình cho mục này.',
      );
      final db = await openTestDatabase(tester);
      await tester.pumpWidget(
        testApp(
          content: ContentBundle(
            version: content.version,
            questions: content.questions,
            structures: content.structures,
            signs: [noImage, ...content.signs.skip(1)],
            signGroups: content.signGroups,
            chapters: content.chapters,
          ),
          db: db,
          store: onboarded('B'),
          now: DateTime(2026, 10, 21, 9),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(S.trafficSigns));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.trafficSigns));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(S.searchSigns));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), noImage.code);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(Card, noImage.code),
      ); // not the search field's own text
      await tester.pumpAndSettle();
      expect(find.text(S.noSignImage), findsOneWidget);
      expect(find.text(noImage.noImageReason!), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Vạch 3.2 có hình nhóm tự vẽ → hiện hình kèm chú thích "do nhóm vẽ"',
    (tester) async {
      await openSigns(tester);
      final drawn = content.signs.firstWhere((s) => s.code == 'Vạch 3.2');
      expect(drawn.images, isNotEmpty);
      expect(drawn.imageNote, contains('do nhóm vẽ'));
      await tester.tap(find.byTooltip(S.searchSigns));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), drawn.code);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Card, drawn.code));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsWidgets);
      expect(find.text(drawn.imageNote!), findsOneWidget);
    },
  );

  testWidgets(
    'tìm "quay dau" không dấu → có P.124a, đếm số biển; chuỗi lạ → "Không tìm thấy" (ST-16)',
    (tester) async {
      await openSigns(tester);
      await tester.tap(find.byTooltip(S.searchSigns));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'quay dau');
      await tester.pumpAndSettle();
      expect(find.text('P.124a'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text(S.noSignFound), findsOneWidget);
    },
  );
}
