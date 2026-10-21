import 'package:flutter/material.dart';

import '../../../core/strings.dart';

enum ExitChoice { submit, saveAndExit, discard, keepGoing }

/// "Kết thúc bài thi?" (ST-09 AC2): submit, save and leave, discard (confirmed), or keep going.
Future<ExitChoice?> showExamExitSheet(
  BuildContext context, {
  required int unanswered,
}) async {
  final choice = await showModalBottomSheet<ExitChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true, // four options with hints: let the sheet grow, scroll on short screens
    builder: (context) {
      final text = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.endTestTitle,
                  style: text.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (unanswered > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    S.unansweredWarning(unanswered),
                    style: text.bodyMedium?.copyWith(color: scheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                _Option(
                  icon: Icons.done_all,
                  title: S.submitAndGrade,
                  subtitle: S.submitAndGradeHint,
                  highlighted: true,
                  onTap: () => Navigator.pop(context, ExitChoice.submit),
                ),
                _Option(
                  icon: Icons.save_outlined,
                  title: S.saveAndExit,
                  subtitle: S.saveAndExitHint,
                  onTap: () => Navigator.pop(context, ExitChoice.saveAndExit),
                ),
                _Option(
                  icon: Icons.delete_outline,
                  title: S.discardAndExit,
                  subtitle: S.discardAndExitHint,
                  danger: true,
                  onTap: () => Navigator.pop(context, ExitChoice.discard),
                ),
                _Option(
                  icon: Icons.play_arrow,
                  title: S.keepGoing,
                  onTap: () => Navigator.pop(context, ExitChoice.keepGoing),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  if (choice != ExitChoice.discard || !context.mounted) return choice;
  final sure = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(S.discardConfirmTitle),
      content: const Text(S.discardConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(S.discard),
        ),
      ],
    ),
  );
  return sure == true ? ExitChoice.discard : ExitChoice.keepGoing;
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.highlighted = false,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool highlighted;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? scheme.error : null;
    return Card(
      color: highlighted ? scheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: onTap,
      ),
    );
  }
}
