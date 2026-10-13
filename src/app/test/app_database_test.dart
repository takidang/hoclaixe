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
