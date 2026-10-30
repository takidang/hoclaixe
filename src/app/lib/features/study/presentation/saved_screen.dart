import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../data/study_providers.dart';
import '../domain/study_topic.dart';

/// Tab "Câu đã lưu": the bookmarked questions of the selected class; study them all, or open one.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cp = ref.watch(classPoolProvider).value;
    final ids = ref.watch(savedIdsProvider).value ?? const {};
    // order of saving and only this class's pool, as in the "Câu đã lưu" topic it opens
    final byId = {for (final q in cp?.pool ?? const <Question>[]) q.id: q};
    final saved = [for (final id in ids) ?byId[id]];
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
                  gradient: AppGradients.bloom,
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
                            Text(S.reviewSaved, style: text.titleLarge),
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
                        ListTile(
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
