import 'package:sqflite/sqflite.dart';

/// Key-value settings (`app_setting` table). An interface so widget tests can use [InMemorySettingsStore].
abstract interface class SettingsStore {
  Future<String?> get(String key);
  Future<void> set(String key, String value);
}

class SqliteSettingsStore implements SettingsStore {
  SqliteSettingsStore(this._db);

  final Database _db;

  @override
  Future<String?> get(String key) async {
    final rows = await _db.query(
      'app_setting',
      where: 'key = ?',
      whereArgs: [key],
    );
    return rows.isEmpty ? null : rows.first['value']! as String;
  }

  @override
  Future<void> set(String key, String value) => _db.insert('app_setting', {
    'key': key,
    'value': value,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([Map<String, String>? initial])
    : _values = {...?initial};

  final Map<String, String> _values;

  @override
  Future<String?> get(String key) async => _values[key];

  @override
  Future<void> set(String key, String value) async => _values[key] = value;
}
