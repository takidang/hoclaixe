// Picks the SQLite implementation per platform: native sqflite on Android/iOS,
// sqlite3.wasm (IndexedDB) in the browser. See ADR-002.
export 'platform_database_native.dart' if (dart.library.js_interop) 'platform_database_web.dart';
