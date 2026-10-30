import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/providers.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/speech/question_reader.dart';
import 'package:hoclaixe/features/exam/data/exam_session_repository.dart';
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
  ExamSessionRepository Function(AppDatabase db)? examSessions,
  QuestionReader? reader,
}) => ProviderScope(
  overrides: [
    contentProvider.overrideWith((ref) async => content),
    databaseProvider.overrideWith((ref) async => db),
    settingsStoreProvider.overrideWith((ref) async => store),
    clockProvider.overrideWithValue(clock ?? () => now),
    questionReaderProvider.overrideWithValue(reader ?? FakeQuestionReader()),
    if (examSessions != null)
      examSessionRepositoryProvider.overrideWith(
        (ref) async => examSessions(db),
      ),
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

/// Text-to-speech without the platform plugin: remembers what was read; [voice] false = no Vietnamese voice.
class FakeQuestionReader implements QuestionReader {
  FakeQuestionReader({this.voice = true});

  final bool voice;
  final spoken = <String>[];
  VoidCallback? _onDone;

  bool get speaking => _onDone != null;

  @override
  Future<void> speak(String text, {required VoidCallback onDone}) async {
    if (!voice) throw const SpeechUnavailable();
    spoken.add(text);
    _onDone = onDone;
  }

  @override
  Future<void> stop() async => finish();

  /// The engine reached the end of the text.
  void finish() {
    final cb = _onDone;
    _onDone = null;
    cb?.call();
  }
}
