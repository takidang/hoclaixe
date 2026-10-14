import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/router.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';

void main() {
  AsyncValue<AppSettings> settings({bool accepted = false, String? cls}) =>
      AsyncData(AppSettings(disclaimerAccepted: accepted, licenseClass: cls));

  test('đang nạp cài đặt → mọi đường dẫn về màn chờ', () {
    expect(
      onboardingRedirect(const AsyncLoading(), Routes.home),
      Routes.splash,
    );
    expect(onboardingRedirect(const AsyncLoading(), Routes.splash), isNull);
  });

  test('chưa đồng ý miễn trừ → mọi đường dẫn về màn miễn trừ (AC1)', () {
    for (final path in [
      Routes.splash,
      Routes.home,
      Routes.about,
      Routes.licenseClass,
    ]) {
      expect(
        onboardingRedirect(settings(), path),
        Routes.disclaimer,
        reason: path,
      );
    }
    expect(onboardingRedirect(settings(), Routes.disclaimer), isNull);
  });

  test('đã đồng ý nhưng chưa chọn hạng → về màn chọn hạng (AC1)', () {
    for (final path in [
      Routes.splash,
      Routes.disclaimer,
      Routes.home,
      Routes.about,
    ]) {
      expect(
        onboardingRedirect(settings(accepted: true), path),
        Routes.licenseClass,
        reason: path,
      );
    }
    expect(
      onboardingRedirect(settings(accepted: true), Routes.licenseClass),
      isNull,
    );
  });

  test('đã chọn hạng → vào thẳng màn chính, vẫn mở được Giới thiệu và đổi hạng (AC3)', () {
    final done = settings(accepted: true, cls: 'A1');
    expect(onboardingRedirect(done, Routes.splash), Routes.home);
    expect(onboardingRedirect(done, Routes.disclaimer), Routes.home);
    expect(onboardingRedirect(done, Routes.home), isNull);
    expect(onboardingRedirect(done, Routes.about), isNull);
    expect(onboardingRedirect(done, Routes.licenseClass), isNull);
  });
}
