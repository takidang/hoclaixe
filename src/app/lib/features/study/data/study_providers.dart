import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/models.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../exam/domain/question_pool.dart';
import '../../exam/domain/structure_picker.dart';
import '../../home/data/home_summary_provider.dart';
import '../domain/study_topic.dart';
import 'progress_repository.dart';

/// The selected class and its question pool.
final classPoolProvider =
    FutureProvider<({String licenseClass, List<Question> pool})?>((ref) async {
      final licenseClass = (await ref.watch(settingsProvider.future))
          .licenseClass;
      if (licenseClass == null) return null;
      final content = await ref.watch(contentProvider.future);
      final structure = StructurePicker.pick(
        content.structures,
        licenseClass,
        ref.read(clockProvider)(),
      )?.structure;
      return (
        licenseClass: licenseClass,
        pool: questionPool(
          content.questions,
          licenseClass,
          pool: structure?.pool,
        ),
      );
    });

/// Topic list with Đúng / Sai / Chưa làm / Tổng (FR-A10).
final topicListProvider = FutureProvider<List<(StudyTopic, TopicStats)>>((
  ref,
) async {
  final cp = await ref.watch(classPoolProvider.future);
  if (cp == null) return const [];
  final progress = await (await ref.watch(progressRepositoryProvider.future))
      .allProgress();
  final lastCorrect = {
    for (final p in progress.values) p.questionId: p.lastCorrect,
  };
  return [
    for (final t in buildTopics(pool: cp.pool, licenseClass: cp.licenseClass))
      (t, TopicStats.of(t, lastCorrect)),
  ];
});

/// Everything the study screen needs when it opens a topic. A `wrong-` topic is a snapshot taken
/// now, so questions do not disappear while being reviewed, and it always starts empty.
class StudyData {
  const StudyData({
    required this.licenseClass,
    required this.topic,
    required this.answers,
    required this.startIndex,
  });

  final String licenseClass;
  final StudyTopic topic;

  /// Choices of the current round.
  final Map<String, int> answers;
  final int startIndex;
}

final studyDataProvider = FutureProvider.autoDispose.family<StudyData?, String>(
  (ref, topicId) async {
    final cp = await ref.watch(classPoolProvider.future);
    if (cp == null) return null;
    final repo = await ref.watch(progressRepositoryProvider.future);
    final topic = resolveTopic(
      topicId,
      pool: cp.pool,
      licenseClass: cp.licenseClass,
      wrongIds: await repo.wrongList(),
      wrongCounts: await repo.wrongCounts(),
    );
    if (topic == null) return null;
    final since = topic.isSnapshot
        ? ref.read(clockProvider)()
        : await repo.roundStart(cp.licenseClass, topicId);
    final answers = topic.isSnapshot
        ? <String, int>{}
        : await repo.latestAnswers(topic.questionIds, since: since);
    final saved = topic.isSnapshot
        ? null
        : await repo.topicPosition(cp.licenseClass, topicId);
    final savedIndex = saved == null ? -1 : topic.questionIds.indexOf(saved);
    return StudyData(
      licenseClass: cp.licenseClass,
      topic: topic,
      answers: answers,
      startIndex: savedIndex < 0 ? 0 : savedIndex,
    );
  },
);

/// Mode written to the answer log for a topic.
/// "Ôn câu sai" logs `wrong`, critical questions `critical`; topics and "Câu hay sai" log `study`.
AnswerMode answerModeOf(StudyTopic topic) => topic.isWrongList
    ? AnswerMode.wrong
    : topic.kind == TopicKind.critical
    ? AnswerMode.critical
    : AnswerMode.study;

/// Call after recording answers so the home screen and topic list show fresh numbers.
void invalidateProgressViews(WidgetRef ref) {
  ref.invalidate(homeSummaryProvider);
  ref.invalidate(topicListProvider);
}
