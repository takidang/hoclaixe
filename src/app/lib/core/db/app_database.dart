import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'platform_database.dart';

/// Learner data in SQLite (ADR-002). Schema: docs/architecture/architecture.md §4.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const fileName = 'hoclaixe.db';
  static const version = 2;

  /// [factory] and [path] are injectable so tests can use sqflite_common_ffi with an in-memory database.
  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await f.getDatabasesPath(), fileName);
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          if (supportsWal) await db.rawQuery('PRAGMA journal_mode = WAL');
        },
        onCreate: (db, _) => _migrate(db, 0, version),
        onUpgrade: _migrate,
        onDowngrade: (_, from, to) => throw StateError(
          'Không hỗ trợ hạ phiên bản cơ sở dữ liệu ($from → $to).',
        ),
      ),
    );
    return AppDatabase._(db);
  }

  /// Each step runs inside the migration transaction opened by sqflite; never drops learner data.
  static Future<void> _migrate(Database db, int from, int to) async {
    for (var v = from + 1; v <= to; v++) {
      for (final sql in _steps[v]!) {
        await db.execute(sql);
      }
    }
  }

  static const Map<int, List<String>> _steps = {
    1: [
      'CREATE TABLE app_setting (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      '''CREATE TABLE question_state (
           question_id TEXT PRIMARY KEY,
           last_correct INTEGER NOT NULL,
           consecutive_correct INTEGER NOT NULL DEFAULT 0,
           wrong_count INTEGER NOT NULL DEFAULT 0,
           in_wrong_list INTEGER NOT NULL DEFAULT 0,
           updated_at INTEGER NOT NULL)''',
      '''CREATE TABLE exam_session (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           license_class TEXT NOT NULL,
           structure_id TEXT NOT NULL,
           fixed_set_no INTEGER,
           question_ids TEXT NOT NULL,
           started_at INTEGER NOT NULL,
           deadline_at INTEGER NOT NULL,
           status TEXT NOT NULL CHECK (status IN ('in_progress', 'submitted', 'abandoned')),
           submitted_at INTEGER,
           score INTEGER,
           passed INTEGER,
           failed_critical INTEGER)''',
      // at most one unfinished test at a time (BR-09)
      "CREATE UNIQUE INDEX one_open_session ON exam_session(status) WHERE status = 'in_progress'",
      '''CREATE TABLE exam_answer (
           session_id INTEGER NOT NULL REFERENCES exam_session(id) ON DELETE CASCADE,
           position INTEGER NOT NULL,
           question_id TEXT NOT NULL,
           selected_index INTEGER,
           flagged INTEGER NOT NULL DEFAULT 0,
           updated_at INTEGER NOT NULL,
           PRIMARY KEY (session_id, position))''',
      '''CREATE TABLE answer_log (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           question_id TEXT NOT NULL,
           mode TEXT NOT NULL CHECK (mode IN ('study', 'wrong', 'critical', 'exam')),
           selected_index INTEGER,
           is_correct INTEGER NOT NULL,
           answered_at INTEGER NOT NULL,
           session_id INTEGER REFERENCES exam_session(id) ON DELETE CASCADE)''',
      // a submitted test is logged once per question (no duplicates if submit is retried)
      'CREATE UNIQUE INDEX one_log_per_exam_question ON answer_log(session_id, question_id) '
          'WHERE session_id IS NOT NULL',
      '''CREATE TABLE topic_position (
           license_class TEXT NOT NULL,
           topic_id TEXT NOT NULL,
           last_question_id TEXT NOT NULL,
           PRIMARY KEY (license_class, topic_id))''',
    ],
    // "Câu đã lưu" (30/10/2026): questions the learner bookmarked
    2: [
      '''CREATE TABLE saved_question (
           question_id TEXT PRIMARY KEY,
           saved_at INTEGER NOT NULL)''',
    ],
  };

  Future<void> close() => db.close();
}
