/// Android/iOS use the sqflite plugin as is.
void configureDatabaseFactory() {}

/// WAL journaling works on device storage.
const supportsWal = true;
