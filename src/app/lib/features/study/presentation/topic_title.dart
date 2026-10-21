import '../../../core/strings.dart';
import '../domain/study_topic.dart';

/// Display name of a topic; [chapters] = official chapter names from the content bundle.
String topicTitle(StudyTopic topic, Map<int, String> chapters) {
  final base = switch (topic.kind) {
    TopicKind.all => S.topicAll,
    TopicKind.critical => S.topicCritical,
    TopicKind.frequent => S.frequentWrong,
    TopicKind.chapter => S.chapterTitle(
      topic.chapter!,
      chapters[topic.chapter] ?? '',
    ),
  };
  return topic.isWrongList ? S.wrongOfTopic(base) : base;
}
