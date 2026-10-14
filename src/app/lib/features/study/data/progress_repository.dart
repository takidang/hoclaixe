import 'package:sqflite/sqflite.dart';

import '../../../core/clock.dart';

enum AnswerMode { study, wrong, critical, exam }

/// Latest learning state of one question (`question_state`).
class QuestionProgress {
  const QuestionProgress({
    required this.questionId,
    required this.lastCorrect,
    required this.consecutiveCorrect,
    required this.wrongCount,
    required this.inWrongList,
  });

  factory QuestionProgress.fromRow(Map<String, Object?> r) => QuestionProgress(
    questionId: r['question_id']! as String,
    lastCorrect: r['last_correct'] == 1,
    consecutiveCorrect: r['consecutive_correct']! as int,
    wrongCount: r['wrong_count']! as int,
    inWrongList: r['in_wrong_list'] == 1,
  );

  final String questionId;
  final bool lastCorrect;
  final int consecutiveCorrect;
  final int wrongCount;
  final bool inWrongList;
}

/// Records answers from study, review and tests; owns the "Câu sai" rule (GA4, FR-A40, FR-A41).
class ProgressRepository {
  ProgressRepository(this._db, {this._clock = systemClock});

  final Database _db;
  final Clock _clock;

  /// Correct answers in a row needed to leave the "Câu sai" list (GA4, decided 13/10/2026).
  static const correctInARowToClear = 2;

  /// Logs one answer and updates the question state in a single transaction.
  Future<void> recordAnswer({
    required String questionId,
    required AnswerMode mode,
    required int? selectedIndex,
    required bool isCorrect,
  }) => _db.transaction(
    (txn) => applyAnswer(
      txn,
      questionId: questionId,
      mode: mode,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      at: _clock(),
    ),
  );

  /// Shared with test submission so both paths follow the same rule. Must run inside a transaction.
  static Future<void> applyAnswer(
    DatabaseExecutor txn, {
    required String questionId,
    required AnswerMode mode,
    required int? selectedIndex,
    required bool isCorrect,
    required DateTime at,
    int? sessionId,
  }) async {
    final now = at.millisecondsSinceEpoch;
    await txn.insert('answer_log', {
      'question_id': questionId,
      'mode': mode.name,
      'selected_index': selectedIndex,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': now,
      'session_id': sessionId,
    });

    final rows = await txn.query(
      'question_state',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    final prev = rows.isEmpty ? null : QuestionProgress.fromRow(rows.first);
    final consecutive = isCorrect ? (prev?.consecutiveCorrect ?? 0) + 1 : 0;
    final inWrongList = isCorrect
        ? (prev?.inWrongList ?? false) && consecutive < correctInARowToClear
        : true;
    await txn.insert('question_state', {
      'question_id': questionId,
      'last_correct': isCorrect ? 1 : 0,
      'consecutive_correct': consecutive,
      'wrong_count': (prev?.wrongCount ?? 0) + (isCorrect ? 0 : 1),
      'in_wrong_list': inWrongList ? 1 : 0,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, QuestionProgress>> allProgress() async {
    final rows = await _db.query('question_state');
    return {
      for (final r in rows)
        r['question_id']! as String: QuestionProgress.fromRow(r),
    };
  }

  Future<Set<String>> wrongList() async {
    final rows = await _db.query(
      'question_state',
      columns: ['question_id'],
      where: 'in_wrong_list = 1',
    );
    return {for (final r in rows) r['question_id']! as String};
  }

  /// Latest chosen option per question among [questionIds], answered after [since]
  /// (any mode; unanswered test questions are skipped). Shows past choices when a topic is reopened.
  Future<Map<String, int>> latestAnswers(
    List<String> questionIds, {
    DateTime? since,
  }) async {
    if (questionIds.isEmpty) return {};
    final marks = List.filled(questionIds.length, '?').join(',');
    final rows = await _db.rawQuery(
      'SELECT question_id, selected_index FROM answer_log '
      'WHERE selected_index IS NOT NULL AND answered_at > ? AND question_id IN ($marks) '
      'ORDER BY id',
      [since?.millisecondsSinceEpoch ?? 0, ...questionIds],
    );
    return {
      for (final r in rows)
        r['question_id']! as String: r['selected_index']! as int,
    };
  }

  /// When the learner last pressed "Làm lại" on a topic (FR-A11); null = never.
  Future<DateTime?> roundStart(String licenseClass, String topicId) async {
    final rows = await _db.query(
      'app_setting',
      where: 'key = ?',
      whereArgs: [_roundKey(licenseClass, topicId)],
    );
    return rows.isEmpty
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            int.parse(rows.first['value']! as String),
          );
  }

  /// Starts a new round: past choices are no longer shown in this topic. Progress and the wrong list are kept.
  Future<DateTime> restartRound(String licenseClass, String topicId) async {
    final now = _clock();
    await _db.insert('app_setting', {
      'key': _roundKey(licenseClass, topicId),
      'value': '${now.millisecondsSinceEpoch}',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return now;
  }

  static String _roundKey(String licenseClass, String topicId) =>
      'study_round:$licenseClass:$topicId';

  Future<String?> topicPosition(String licenseClass, String topicId) async {
    final rows = await _db.query(
      'topic_position',
      where: 'license_class = ? AND topic_id = ?',
      whereArgs: [licenseClass, topicId],
    );
    return rows.isEmpty ? null : rows.first['last_question_id']! as String;
  }

  Future<void> saveTopicPosition(
    String licenseClass,
    String topicId,
    String questionId,
  ) => _db.insert('topic_position', {
    'license_class': licenseClass,
    'topic_id': topicId,
    'last_question_id': questionId,
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}
