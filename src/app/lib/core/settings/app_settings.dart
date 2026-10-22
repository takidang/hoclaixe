import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'settings_store.dart';

/// Licence classes supported by Module A (vision §5).
const supportedLicenseClasses = ['A1', 'A', 'B'];

class AppSettings {
  const AppSettings({
    required this.disclaimerAccepted,
    required this.licenseClass,
    this.themeMode = ThemeMode.system,
  });

  final bool disclaimerAccepted;

  /// null until the learner picks a class (FR-A03).
  final String? licenseClass;

  /// Light, dark or follow the device (ST-13, chosen on the About screen).
  final ThemeMode themeMode;

  AppSettings copyWith({bool? disclaimerAccepted, String? licenseClass, ThemeMode? themeMode}) => AppSettings(
        disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
        licenseClass: licenseClass ?? this.licenseClass,
        themeMode: themeMode ?? this.themeMode,
      );
}

abstract final class SettingKeys {
  static const disclaimerAccepted = 'disclaimer_accepted';
  static const licenseClass = 'license_class';
  static const themeMode = 'theme_mode';
}

/// Where settings are stored; overridden in widget tests with an in-memory store.
final settingsStoreProvider = FutureProvider<SettingsStore>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return SqliteSettingsStore(db.db);
});

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final store = await ref.watch(settingsStoreProvider.future);
    final cls = await store.get(SettingKeys.licenseClass);
    return AppSettings(
      disclaimerAccepted:
          await store.get(SettingKeys.disclaimerAccepted) == '1',
      licenseClass: supportedLicenseClasses.contains(cls) ? cls : null,
      themeMode: ThemeMode.values.asNameMap()[await store.get(SettingKeys.themeMode)] ?? ThemeMode.system,
    );
  }

  /// FR-A01: saved once, never asked again.
  Future<void> acceptDisclaimer() async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.set(SettingKeys.disclaimerAccepted, '1');
    state = AsyncData(state.requireValue.copyWith(disclaimerAccepted: true));
  }

  /// FR-A03, FR-A04.
  Future<void> chooseLicenseClass(String licenseClass) async {
    if (!supportedLicenseClasses.contains(licenseClass)) {
      throw ArgumentError.value(
        licenseClass,
        'licenseClass',
        'Hạng chưa được hỗ trợ',
      );
    }
    final store = await ref.read(settingsStoreProvider.future);
    await store.set(SettingKeys.licenseClass, licenseClass);
    state = AsyncData(state.requireValue.copyWith(licenseClass: licenseClass));
  }

  /// Saved as 'system' / 'light' / 'dark'; the whole app restyles immediately.
  Future<void> setThemeMode(ThemeMode mode) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.set(SettingKeys.themeMode, mode.name);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }
}
