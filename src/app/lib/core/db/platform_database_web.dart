import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Browser: sqlite3.wasm in a shared worker, data kept in IndexedDB (web/sqlite3.wasm, web/sqflite_sw.js).
void configureDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}

/// The IndexedDB-backed file system has no WAL support.
const supportsWal = false;
