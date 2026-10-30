import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../core/strings.dart';

/// "Tự chuyển câu" on the study and test screens: one tap turns it on or off while answering
/// (same setting as on the About screen).
class AutoNextToggle extends ConsumerWidget {
  const AutoNextToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider).value?.autoNext ?? false;
    return IconButton(
      tooltip: on ? S.autoNextIsOn : S.autoNextIsOff,
      isSelected: on,
      icon: const Icon(Icons.fast_forward_outlined),
      selectedIcon: const Icon(Icons.fast_forward_rounded),
      onPressed: () async {
        unawaited(HapticFeedback.selectionClick());
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(settingsProvider.notifier).setAutoNext(!on);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(on ? S.autoNextTurnedOff : S.autoNextTurnedOn),
              duration: const Duration(milliseconds: 1500),
            ),
          );
      },
    );
  }
}
