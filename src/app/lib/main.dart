import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/strings.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // portrait only (SRS §2.3)
  runApp(const ProviderScope(child: HoclaixeApp()));
}

class HoclaixeApp extends StatelessWidget {
  const HoclaixeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: S.appName,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    routerConfig: appRouter,
    debugShowCheckedModeBanner: false,
  );
}
