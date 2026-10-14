import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';
import 'package:hoclaixe/core/providers.dart';
import 'package:hoclaixe/core/settings/app_settings.dart';
import 'package:hoclaixe/core/settings/settings_store.dart';
import 'package:hoclaixe/core/strings.dart';
import 'package:hoclaixe/features/home/presentation/home_screen.dart';

void main() {
  Widget app(Future<ContentBundle> Function() load) => ProviderScope(
    overrides: [
      contentProvider.overrideWith((ref) => load()),
      settingsStoreProvider.overrideWith(
        (ref) async => InMemorySettingsStore(),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );

  testWidgets('shows loaded content counts', (tester) async {
    const bundle = ContentBundle(
      version: 'test-1',
      questions: [],
      structures: [],
      signs: [],
      signGroups: {},
    );
    await tester.pumpWidget(app(() async => bundle));
    await tester.pumpAndSettle();
    expect(find.text(S.contentLoaded(0, 0)), findsOneWidget);
    expect(find.text(S.contentVersion('test-1')), findsOneWidget);
  });

  testWidgets('shows a clear message when content cannot be read', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(() async => throw const FormatException('bad')),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.contentError), findsOneWidget);
  });
}
