import '../../../core/content/models.dart';

/// A list of questions studied in order (FR-A10). Pure Dart.
///
/// Ids: `all`, `critical`, `ch1`…`ch6`, and `wrong-<base id>` = the wrong-list questions of a base topic.
class StudyTopic {
  const StudyTopic({
    required this.id,
    required this.kind,
    required this.chapter,
    required this.questions,
  });

  final String id;
  final TopicKind kind;

  /// Chapter number for [TopicKind.chapter] (or the base topic of a wrong-list topic), else null.
  final int? chapter;

  /// In official order.
  final List<Question> questions;

  List<String> get questionIds => [for (final q in questions) q.id];

  static const allId = 'all';
  static const criticalId = 'critical';
  static const wrongPrefix = 'wrong-';
  static String chapterId(int chapter) => 'ch$chapter';
  static String wrongOf(String baseId) => '$wrongPrefix$baseId';

  bool get isWrongList => id.startsWith(wrongPrefix);

  /// Base topic for a wrong-list topic, otherwise itself.
  String get baseId => isWrongList ? id.substring(wrongPrefix.length) : id;
}

enum TopicKind { all, critical, chapter }

/// "Tất cả câu hỏi", "Câu điểm liệt", then every chapter that has questions in the class pool.
List<StudyTopic> buildTopics({
  required List<Question> pool,
  required String licenseClass,
}) {
  final chapters = {for (final q in pool) q.chapter}.toList()..sort();
  return [
    StudyTopic(
      id: StudyTopic.allId,
      kind: TopicKind.all,
      chapter: null,
      questions: pool,
    ),
    StudyTopic(
      id: StudyTopic.criticalId,
      kind: TopicKind.critical,
      chapter: null,
      questions: [
        for (final q in pool)
          if (q.isCriticalFor(licenseClass)) q,
      ],
    ),
    for (final c in chapters)
      StudyTopic(
        id: StudyTopic.chapterId(c),
        kind: TopicKind.chapter,
        chapter: c,
        questions: [
          for (final q in pool)
            if (q.chapter == c) q,
        ],
      ),
  ];
}

/// Finds a topic by id; a `wrong-` topic keeps only the base topic's questions in [wrongIds]. Null if unknown.
StudyTopic? resolveTopic(
  String id, {
  required List<Question> pool,
  required String licenseClass,
  required Set<String> wrongIds,
}) {
  final topics = buildTopics(pool: pool, licenseClass: licenseClass);
  if (id.startsWith(StudyTopic.wrongPrefix)) {
    final base = resolveTopic(
      id.substring(StudyTopic.wrongPrefix.length),
      pool: pool,
      licenseClass: licenseClass,
      wrongIds: wrongIds,
    );
    if (base == null || base.isWrongList) return null;
    return StudyTopic(
      id: id,
      kind: base.kind,
      chapter: base.chapter,
      questions: [
        for (final q in base.questions)
          if (wrongIds.contains(q.id)) q,
      ],
    );
  }
  for (final t in topics) {
    if (t.id == id) return t;
  }
  return null;
}

/// Đúng / Sai / Chưa làm / Tổng by the latest result of each question, from study, review and tests (FR-A10).
class TopicStats {
  const TopicStats({
    required this.correct,
    required this.wrong,
    required this.total,
  });

  /// [lastCorrect]: question id -> whether its latest answer was correct (only answered questions).
  factory TopicStats.of(StudyTopic topic, Map<String, bool> lastCorrect) {
    var correct = 0;
    var wrong = 0;
    for (final q in topic.questions) {
      switch (lastCorrect[q.id]) {
        case true:
          correct++;
        case false:
          wrong++;
        case null:
          break;
      }
    }
    return TopicStats(
      correct: correct,
      wrong: wrong,
      total: topic.questions.length,
    );
  }

  final int correct;
  final int wrong;
  final int total;

  int get notDone => total - correct - wrong;
  double get progress => total == 0 ? 0 : correct / total;
}

/// Result of the current round of a topic (AC4).
class RoundSummary {
  const RoundSummary({
    required this.correct,
    required this.wrong,
    required this.total,
  });

  /// [answers]: question id -> chosen option in this round.
  factory RoundSummary.of(StudyTopic topic, Map<String, int> answers) {
    var correct = 0;
    var wrong = 0;
    for (final q in topic.questions) {
      final a = answers[q.id];
      if (a == null) continue;
      if (a == q.correctIndex) {
        correct++;
      } else {
        wrong++;
      }
    }
    return RoundSummary(
      correct: correct,
      wrong: wrong,
      total: topic.questions.length,
    );
  }

  final int correct;
  final int wrong;
  final int total;

  bool get finished => total > 0 && correct + wrong == total;
}
