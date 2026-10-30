import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/models.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/study_providers.dart';
import '../domain/question_search.dart';
import '../domain/study_topic.dart';

/// "Tìm câu hỏi": by official number or by words, without diacritics, in the selected class's pool.
class QuestionSearchScreen extends ConsumerStatefulWidget {
  const QuestionSearchScreen({super.key});

  @override
  ConsumerState<QuestionSearchScreen> createState() =>
      _QuestionSearchScreenState();
}

class _QuestionSearchScreenState extends ConsumerState<QuestionSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(classPoolProvider).value;
    final results = cp == null
        ? const <Question>[]
        : searchQuestions(cp.pool, _query);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: S.searchQuestionsHint,
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.trim().isEmpty
          ? const _Hint(text: S.searchQuestionsEmpty)
          : results.isEmpty
          ? const _Hint(text: S.noQuestionFound)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length + 1,
              separatorBuilder: (_, i) =>
                  i == 0 ? const SizedBox.shrink() : const Divider(indent: 16),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      S.questionResults(results.length),
                      style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  );
                }
                final q = results[i - 1];
                return ListTile(
                  leading: Text(
                    '${q.number}',
                    style: AppTheme.mono(text.titleSmall, scheme.primary),
                  ),
                  title: Text(
                    q.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () =>
                      context.push(Routes.studyTopic(StudyTopic.single(q.id))),
                );
              },
            ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}
