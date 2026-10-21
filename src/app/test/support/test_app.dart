import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/providers.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A fresh in-memory learner database. The no-isolate factory lets queries finish inside
/// widget tests' fake async zone, so `pumpAndSettle` waits for them.
Future<AppDatabase> openTestDatabase(WidgetTester tester) async {
  sqfliteFfiInit();
  final db = await tester.runAsync(
    () => AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    ),
  );
  addTearDown(db!.close);
  return db;
}

/// The whole app with test data: real or given content, in-memory settings and database, fixed clock
/// ([clock] instead of [now] when a test moves time forward).
Widget testApp({
  required ContentBundle content,
  required AppDatabase db,
  required InMemorySettingsStore store,
  required DateTime now,
  DateTime Function()? clock,
}) => ProviderScope(
  overrides: [
    contentProvider.overrideWith((ref) async => content),
    databaseProvider.overrideWith((ref) async => db),
    settingsStoreProvider.overrideWith((ref) async => store),
    clockProvider.overrideWithValue(clock ?? () => now),
  ],
  child: const HoclaixeApp(),
);

/// Settings of a learner who already finished onboarding with [licenseClass].
InMemorySettingsStore onboarded(String licenseClass) => InMemorySettingsStore({
  SettingKeys.disclaimerAccepted: '1',
  SettingKeys.licenseClass: licenseClass,
});

/// The home screen's title shows the selected class.
Finder homeTitle(String className) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(className));
