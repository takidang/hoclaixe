import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

void main() {
  final content = loadRealContent();

  Future<void> open(WidgetTester tester, InMemorySettingsStore store) async {
    final db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: store,
        now: DateTime(2026, 10, 22, 9),
      ),
    );
    await tester.pumpAndSettle();
  }

  Brightness brightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

  testWidgets(
    'Giới thiệu → chọn "Tối": app tối ngay, lựa chọn được lưu; "Sáng" thì sáng lại',
    (tester) async {
      final store = onboarded('A1');
      await open(tester, store);
      expect(
        brightness(tester),
        Brightness.light,
        reason: 'mặc định theo máy (máy test: sáng)',
      );

      await tester.tap(find.byTooltip(S.about));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.themeDark));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.dark);
      expect(await store.get(SettingKeys.themeMode), 'dark');

      await tester.tap(find.text(S.themeLight));
      await tester.pumpAndSettle();
      expect(brightness(tester), Brightness.light);
      expect(await store.get(SettingKeys.themeMode), 'light');
    },
  );

  testWidgets('mở lại app giữ lựa chọn "Sáng" dù máy đang ở chế độ tối', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await open(
      tester,
      InMemorySettingsStore({
        ...{
          SettingKeys.disclaimerAccepted: '1',
          SettingKeys.licenseClass: 'A1',
          SettingKeys.themeMode: 'light',
        },
      }),
    );
    expect(brightness(tester), Brightness.light);
  });

  testWidgets('"Theo máy": máy tối thì app tối', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await open(tester, onboarded('A1'));
    expect(brightness(tester), Brightness.dark);
  });
}
