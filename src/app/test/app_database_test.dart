import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase app;
  setUp(
    () async => app = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    ),
  );
  tearDown(() => app.close());

  Map<String, Object?> session(int now) => {
    'license_class': 'B',
    'structure_id': 'B-2025',
    'question_ids': '["Q0001"]',
    'started_at': now,
    'deadline_at': now + 20 * 60 * 1000,
    'status': 'in_progress',
  };

  test('creates the six tables of schema v1', () async {
    final rows = await app.db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = rows.map((r) => r['name']).toSet();
    expect(
      names,
      containsAll([
        'app_setting',
        'question_state',
        'answer_log',
        'topic_position',
        'exam_session',
        'exam_answer',
      ]),
    );
  });

  test(
    'v1 → v2 (30/10/2026): adds saved_question and keeps existing progress',
    () async {
      final path =
          '${(await databaseFactoryFfi.getDatabasesPath())}/upgrade_test.db';
      await databaseFactoryFfi.deleteDatabase(path);
      // a learner's database from the previous release (schema v1, one answered question)
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE question_state (question_id TEXT PRIMARY KEY, last_correct INTEGER NOT NULL)',
            );
            await db.insert('question_state', {
              'question_id': 'Q0001',
              'last_correct': 1,
            });
          },
        ),
      );
      await old.close();

      final upgraded = await AppDatabase.open(
        factory: databaseFactoryFfi,
        path: path,
      );
      addTearDown(() async {
        await upgraded.close();
        await databaseFactoryFfi.deleteDatabase(path);
      });
      expect(await upgraded.db.getVersion(), AppDatabase.version);
      expect(await upgraded.db.query('question_state'), hasLength(1));
      await upgraded.db.insert('saved_question', {
        'question_id': 'Q0001',
        'saved_at': 1,
      });
      expect(await upgraded.db.query('saved_question'), hasLength(1));
    },
  );

  test('allows at most one unfinished test (BR-09)', () async {
    await app.db.insert('exam_session', session(1));
    expect(
      () => app.db.insert('exam_session', session(2)),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('foreign keys are enforced', () async {
    final orphan = {
      'session_id': 999,
      'position': 0,
      'question_id': 'Q0001',
      'updated_at': 1,
    };
    expect(
      () => app.db.insert('exam_answer', orphan),
      throwsA(isA<DatabaseException>()),
    );
  });
}
