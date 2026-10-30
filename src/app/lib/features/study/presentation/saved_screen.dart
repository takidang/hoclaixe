import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../data/study_providers.dart';
import '../domain/study_topic.dart';

/// Tab "Câu đã lưu": the bookmarked questions of the selected class; study them all, open one, or swipe one
/// away (with undo).
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  /// Swiped away and not yet gone from the saved list (a dismissed row must leave the tree at once).
  final _hidden = <String>{};

  Future<void> _unsave(String id) async {
    setState(() => _hidden.add(id));
    unawaited(HapticFeedback.mediumImpact());
    final messenger = ScaffoldMessenger.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final DateTime? savedAt;
    try {
      final repo = await ref.read(progressRepositoryProvider.future);
      savedAt = await repo.savedAt(id);
      await toggleSaved(ref, id);
    } on Exception {
      // not removed: show it again and say so, rather than letting it vanish
      if (mounted) setState(() => _hidden.remove(id));
      messenger.showSnackBar(
        SnackBar(
          content: const Text(S.saveFailed),
          margin: EdgeInsets.fromLTRB(16, 0, 16, bottom + 8),
        ),
      );
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(S.unsaved),
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            bottom + 8,
          ), // above the tab bar
          action: SnackBarAction(
            label: S.undo,
            onPressed: () async {
              await toggleSaved(ref, id, at: savedAt);
              if (mounted) setState(() => _hidden.remove(id));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(classPoolProvider).value;
    final ids = ref.watch(savedIdsProvider).value ?? const {};
    _hidden.removeWhere((id) => !ids.contains(id)); // the store caught up
    // order of saving and only this class's pool, as in the "Câu đã lưu" topic it opens
    final byId = {for (final q in cp?.pool ?? const <Question>[]) q.id: q};
    final saved = [
      for (final id in ids)
        if (!_hidden.contains(id)) ?byId[id],
    ];
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return Scaffold(
      appBar: AppBar(title: const Text(S.savedQuestions)),
      body: saved.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottom),
                child: Text(
                  '${S.noSavedYet}\n\n${S.noSavedYetHint}',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium,
                ),
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
              children: [
                GradientCard(
                  tone: CardTone.bloom,
                  onTap: () =>
                      context.push(Routes.studyTopic(StudyTopic.savedId)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CountChip(
                              icon: Icons.bookmark,
                              label: S.questionCount(saved.length),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              S.reviewSaved,
                              style: AppTheme.cardText(context).titleLarge,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < saved.length; i++) ...[
                        if (i > 0) const Divider(indent: 64),
                        Dismissible(
                          key: ValueKey(saved[i].id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _unsave(saved[i].id),
                          background: ColoredBox(
                            color: scheme.errorContainer,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      S.unsaveQuestion,
                                      style: text.labelLarge?.copyWith(
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.bookmark_remove_outlined,
                                      color: scheme.onErrorContainer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: SizedBox(
                              width: 32,
                              child: Text(
                                '${saved[i].number}',
                                style: AppTheme.mono(
                                  text.titleSmall,
                                  scheme.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              saved[i].content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => context.push(
                              Routes.studyTopic(StudyTopic.single(saved[i].id)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
