import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/router.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/core/theme/app_theme.dart';
import 'package:hoclaixe/shared/widgets/class_photo.dart';

import '../../support/real_content.dart';
import '../../support/test_app.dart';

/// Experiment "ảnh xe": start screen, class photos, card colours per mode.
void main() {
  final content = loadRealContent();
  final now = DateTime(2026, 10, 30, 9);

  Future<void> open(
    WidgetTester tester, {
    bool startScreen = false,
    String theme = 'light',
  }) async {
    final db = await openTestDatabase(tester);
    await tester.pumpWidget(
      testApp(
        content: content,
        db: db,
        store: InMemorySettingsStore({
          SettingKeys.disclaimerAccepted: '1',
          SettingKeys.licenseClass: 'A1',
          SettingKeys.themeMode: theme,
        }),
        now: now,
        startScreen: startScreen,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder photo(String asset) => find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == asset,
  );

  test('mở app (đã chọn hạng): có màn mở đầu thì vào /start, không thì vào thẳng màn chính', () {
    const done = AsyncData(
      AppSettings(disclaimerAccepted: true, licenseClass: 'B'),
    );
    expect(
      onboardingRedirect(done, Routes.splash, startScreen: true),
      Routes.start,
    );
    expect(onboardingRedirect(done, Routes.splash), Routes.home);
    expect(onboardingRedirect(done, Routes.start, startScreen: true), isNull);
  });

  testWidgets('màn mở đầu: ảnh siêu xe, nút "Bắt đầu" vào màn chính', (
    tester,
  ) async {
    await open(tester, startScreen: true);
    expect(photo(ClassPhotos.start), findsOneWidget);
    expect(find.text(S.startTitle), findsOneWidget);
    await tester.tap(find.text(S.startButton));
    await tester.pumpAndSettle();
    expect(homeTitle(S.className('A1')), findsOneWidget);
  });

  testWidgets(
    'màn chính dùng ảnh xe của hạng đang chọn; màn chọn hạng có ảnh từng hạng; chọn B thì đổi ảnh',
    (tester) async {
      tester.view.physicalSize = const Size(
        800,
        2400,
      ); // the three class cards on one screen
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await open(tester);
      expect(photo(ClassPhotos.of('A1')!), findsOneWidget);

      await tester.tap(find.text(S.changeClass));
      await tester.pumpAndSettle();
      for (final cls in ['A', 'B']) {
        expect(photo(ClassPhotos.of(cls)!), findsOneWidget, reason: cls);
      }
      await chooseClass(tester, S.className('B'));
      expect(homeTitle(S.className('B')), findsOneWidget);
      expect(photo(ClassPhotos.of('B')!), findsOneWidget);
      expect(photo(ClassPhotos.of('A1')!), findsNothing);
    },
  );

  for (final (theme, ink) in [
    ('dark', CardPalette.dark.ink),
    ('light', CardPalette.light.ink),
  ]) {
    testWidgets(
      'nền $theme: chữ trên thẻ gradient lấy màu của bảng màu thẻ, không lấy màu chữ màn hình',
      (tester) async {
        await open(tester, theme: theme);
        expect(
          tester.widget<Text>(find.text(S.practiceExam)).style?.color,
          ink,
        );
      },
    );
  }
}
