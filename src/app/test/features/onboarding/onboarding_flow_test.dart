import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

void main() {
  final content = loadRealContent();
  final today = DateTime(2026, 10, 14);

  Future<void> start(WidgetTester tester, InMemorySettingsStore store) async {
    final db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(content: content, db: db, store: store, now: today),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'lần đầu: miễn trừ → chọn hạng → màn chính, và lưu lại lựa chọn (AC1)',
    (tester) async {
      final store = InMemorySettingsStore();
      await start(tester, store);
      expect(find.text(S.disclaimerTitle), findsOneWidget);

      await tester.tap(find.text(S.disclaimerAccept));
      await tester.pumpAndSettle();
      expect(find.text(S.chooseClassTitle), findsOneWidget);
      expect(await store.get(SettingKeys.disclaimerAccepted), '1');

      await chooseClass(tester, S.className('A1'));
      expect(homeTitle(S.className('A1')), findsOneWidget);
      expect(await store.get(SettingKeys.licenseClass), 'A1');
    },
  );

  testWidgets(
    'màn chọn hạng: nhóm Xe máy / Ô tô, loại xe theo luật, số câu – thời gian – điểm đạt (AC2)',
    (tester) async {
      // a tall screen: the three photo cards fit without scrolling
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(
        tester,
        InMemorySettingsStore({SettingKeys.disclaimerAccepted: '1'}),
      );
      expect(find.text(S.motorbikeGroup), findsOneWidget);
      expect(find.text(S.carGroup), findsOneWidget);
      for (final cls in supportedLicenseClasses) {
        expect(find.text(S.classVehicles[cls]!), findsOneWidget, reason: cls);
        final s = StructurePicker.pick(
          content.structures,
          cls,
          today,
        )!.structure;
        expect(
          find.text(
            S.classFacts(s.questionCount, s.durationMinutes, s.passScore),
          ),
          findsWidgets,
          reason: cls,
        );
      }
    },
  );

  testWidgets(
    'đã chọn hạng: mở lại app vào thẳng màn chính, không hiện miễn trừ (AC3)',
    (tester) async {
      await start(tester, onboarded('B'));
      expect(homeTitle(S.className('B')), findsOneWidget);
      expect(find.text(S.disclaimerTitle), findsNothing);
    },
  );

  testWidgets('hạng lưu trong máy không còn hỗ trợ → hỏi chọn lại', (
    tester,
  ) async {
    await start(tester, onboarded('C1'));
    expect(find.text(S.chooseClassTitle), findsOneWidget);
  });

  testWidgets(
    'Giới thiệu: miễn trừ, nguồn, phiên bản dữ liệu và app, tiến độ chỉ lưu trên máy (AC4)',
    (tester) async {
      await start(tester, onboarded('B'));
      await tester.tap(find.byTooltip(S.about));
      await tester.pumpAndSettle();
      expect(find.text(S.disclaimerBody), findsOneWidget);
      for (final source in S.sources) {
        expect(find.text('• $source'), findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.text('${S.appName} ${S.appVersion}'),
        100,
        // SelectableText has its own Scrollable; scroll the page list.
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(S.progressLocalOnly), findsOneWidget);
      expect(find.text(S.contentVersion(content.version)), findsOneWidget);
    },
  );
}
