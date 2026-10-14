import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/providers.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';
import 'package:hoclaixe/main.dart';

import '../../support/real_content.dart';

void main() {
  final content = loadRealContent();
  final today = DateTime(2026, 10, 14);

  Widget app(InMemorySettingsStore store) => ProviderScope(
    overrides: [
      contentProvider.overrideWith((ref) async => content),
      settingsStoreProvider.overrideWith((ref) async => store),
      clockProvider.overrideWithValue(() => today),
    ],
    child: const HoclaixeApp(),
  );

  testWidgets(
    'lần đầu: miễn trừ → chọn hạng → màn chính, và lưu lại lựa chọn (AC1)',
    (tester) async {
      final store = InMemorySettingsStore();
      await tester.pumpWidget(app(store));
      await tester.pumpAndSettle();
      expect(find.text(S.disclaimerTitle), findsOneWidget);

      await tester.tap(find.text(S.disclaimerAccept));
      await tester.pumpAndSettle();
      expect(find.text(S.chooseClassTitle), findsOneWidget);
      expect(await store.get(SettingKeys.disclaimerAccepted), '1');

      await tester.tap(find.text(S.className('A1')));
      await tester.pumpAndSettle();
      expect(find.text(S.currentClass('A1')), findsOneWidget);
      expect(await store.get(SettingKeys.licenseClass), 'A1');
    },
  );

  testWidgets(
    'màn chọn hạng: nhóm Xe máy / Ô tô, số câu – thời gian – điểm đạt lấy từ cấu trúc đề (AC2)',
    (tester) async {
      await tester.pumpWidget(
        app(InMemorySettingsStore({SettingKeys.disclaimerAccepted: '1'})),
      );
      await tester.pumpAndSettle();
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
      await tester.pumpWidget(
        app(
          InMemorySettingsStore({
            SettingKeys.disclaimerAccepted: '1',
            SettingKeys.licenseClass: 'B',
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.currentClass('B')), findsOneWidget);
      expect(find.text(S.disclaimerTitle), findsNothing);
    },
  );

  testWidgets('đổi hạng từ màn chính (FR-A04)', (tester) async {
    final store = InMemorySettingsStore({
      SettingKeys.disclaimerAccepted: '1',
      SettingKeys.licenseClass: 'B',
    });
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.changeClass));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.className('A')));
    await tester.pumpAndSettle();
    expect(find.text(S.currentClass('A')), findsOneWidget);
    expect(await store.get(SettingKeys.licenseClass), 'A');
  });

  testWidgets('hạng lưu trong máy không còn hỗ trợ → hỏi chọn lại', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        InMemorySettingsStore({
          SettingKeys.disclaimerAccepted: '1',
          SettingKeys.licenseClass: 'C1',
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.chooseClassTitle), findsOneWidget);
  });

  testWidgets(
    'Giới thiệu: miễn trừ, nguồn, phiên bản dữ liệu và app, tiến độ chỉ lưu trên máy (AC4)',
    (tester) async {
      await tester.pumpWidget(
        app(
          InMemorySettingsStore({
            SettingKeys.disclaimerAccepted: '1',
            SettingKeys.licenseClass: 'B',
          }),
        ),
      );
      await tester.pumpAndSettle();
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
