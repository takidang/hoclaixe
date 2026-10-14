import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/db/app_database.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late AppDatabase app;
  late SqliteSettingsStore store;

  setUp(() async {
    app = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqliteSettingsStore(app.db);
  });
  tearDown(() => app.close());

  test('khóa chưa lưu trả về null', () async {
    expect(await store.get('license_class'), isNull);
  });

  test('lưu rồi đọc lại đúng giá trị; lưu lần hai ghi đè', () async {
    await store.set('license_class', 'A1');
    await store.set('license_class', 'B');
    expect(await store.get('license_class'), 'B');
  });
}
