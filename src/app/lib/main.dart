import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/platform_database.dart';
import 'core/router.dart';
import 'core/settings/app_settings.dart';
import 'core/strings.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory(); // web: sqlite3.wasm instead of the sqflite plugin
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // portrait only (SRS §2.3)
  runApp(const ProviderScope(child: HoclaixeApp()));
}

class HoclaixeApp extends ConsumerWidget {
  const HoclaixeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: S.appName,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.system,
    routerConfig: ref.watch(routerProvider),
    debugShowCheckedModeBanner: false,
  );
}
