import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/clock.dart';
import '../../../core/content/models.dart';
import '../../study/data/progress_repository.dart';
import '../domain/exam_grader.dart';
import '../domain/exam_paper.dart';
import '../domain/exam_session.dart';

/// Thrown when a new test is started while another one is unfinished (BR-09).
class OpenSessionExistsException implements Exception {
  const OpenSessionExistsException();

  @override
  String toString() => 'Đang có một bài thi chưa nộp.';
}

/// Persists tests so answers are never lost or changed (FR-A24–A26, NFR-02, BR-09).
class ExamSessionRepository {
  ExamSessionRepository(this._db, {this._clock = systemClock});

  final Database _db;
  final Clock _clock;

  static const _inProgress = 'in_progress';

  /// Creates the session and one answer row per position in one transaction. The paper is a snapshot (BR-09).
  Future<ExamSession> start(ExamPaper paper, ExamStructure structure) async {
    final now = _clock();
    final deadline = now.add(Duration(minutes: structure.durationMinutes));
    try {
      final id = await _db.transaction((txn) async {
        final id = await txn.insert('exam_session', {
          'license_class': paper.licenseClass,
          'structure_id': paper.structureId,
          'fixed_set_no': paper.fixedSetNo,
          'question_ids': jsonEncode({
            'questionIds': paper.questionIds,
            'criticalQuestionId': paper.criticalQuestionId,
          }),
          'started_at': now.millisecondsSinceEpoch,
          'deadline_at': deadline.millisecondsSinceEpoch,
          'status': _inProgress,
        });
        final batch = txn.batch();
        for (var i = 0; i < paper.length; i++) {
          batch.insert('exam_answer', {
            'session_id': id,
            'position': i,
            'question_id': paper.questionIds[i],
            'updated_at': now.millisecondsSinceEpoch,
          });
        }
        await batch.commit(noResult: true);
        return id;
      });
      return (await byId(id))!;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw const OpenSessionExistsException();
      rethrow;
    }
  }

  /// The unfinished test, if any (check [ExamSession.isExpired] → submit right away, FR-A25).
  Future<ExamSession?> openSession() async {
    final rows = await _db.query(
      'exam_session',
      columns: ['id'],
      where: 'status = ?',
      whereArgs: [_inProgress],
    );
    return rows.isEmpty ? null : byId(rows.first['id']! as int);
  }

  Future<ExamSession?> byId(int id) async {
    final rows = await _db.query(
      'exam_session',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    final snapshot =
        jsonDecode(r['question_ids']! as String) as Map<String, dynamic>;
    final answers = await _db.query(
      'exam_answer',
      where: 'session_id = ?',
      whereArgs: [id],
      orderBy: 'position',
    );
    return ExamSession(
      id: id,
      paper: ExamPaper(
        licenseClass: r['license_class']! as String,
        structureId: r['structure_id']! as String,
        questionIds: List<String>.unmodifiable(
          snapshot['questionIds'] as List<dynamic>,
        ),
        criticalQuestionId: snapshot['criticalQuestionId'] as String,
        fixedSetNo: r['fixed_set_no'] as int?,
      ),
      startedAt: DateTime.fromMillisecondsSinceEpoch(r['started_at']! as int),
      deadlineAt: DateTime.fromMillisecondsSinceEpoch(r['deadline_at']! as int),
      status: switch (r['status']) {
        'submitted' => ExamStatus.submitted,
        'abandoned' => ExamStatus.abandoned,
        _ => ExamStatus.inProgress,
      },
      answers: [for (final a in answers) a['selected_index'] as int?],
      flagged: [for (final a in answers) a['flagged'] == 1],
    );
  }

  /// Saves the chosen option; completes only after the row is written (UI updates after this, NFR-02).
  /// Ignored once the test is no longer in progress.
  Future<void> saveAnswer(int sessionId, int position, int? selectedIndex) =>
      _updateAnswer(sessionId, position, {'selected_index': selectedIndex});

  Future<void> setFlag(int sessionId, int position, {required bool flagged}) =>
      _updateAnswer(sessionId, position, {'flagged': flagged ? 1 : 0});

  Future<void> _updateAnswer(
    int sessionId,
    int position,
    Map<String, Object?> values,
  ) async {
    final changed = await _db.rawUpdate(
      'UPDATE exam_answer SET ${values.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
      'WHERE session_id = ? AND position = ? '
      'AND EXISTS (SELECT 1 FROM exam_session WHERE id = ? AND status = ?)',
      [
        ...values.values,
        _clock().millisecondsSinceEpoch,
        sessionId,
        position,
        sessionId,
        _inProgress,
      ],
    );
    if (changed != 1) {
      throw StateError(
        'Không lưu được đáp án (bài $sessionId, vị trí $position).',
      );
    }
  }

  /// Submits once (FR-A26, UC-04 E3): status change, result, answer log and question states in one transaction.
  /// The answers are re-read from the database inside the transaction and [grade] runs on exactly those, so the
  /// result always matches what was saved — never a stale copy held by the UI (FR-A24, "khớp 100%").
  /// Returns null when the test was already submitted — nothing is graded or logged twice.
  Future<ExamResult?> submit(
    ExamSession session,
    ExamResult Function(List<int?> savedAnswers) grade,
  ) {
    final now = _clock();
    return _db.transaction((txn) async {
      final saved = await txn.query(
        'exam_answer',
        columns: ['selected_index'],
        where: 'session_id = ?',
        whereArgs: [session.id],
        orderBy: 'position',
      );
      final answers = [for (final r in saved) r['selected_index'] as int?];
      final result = grade(answers);
      final changed = await txn.rawUpdate(
        'UPDATE exam_session SET status = ?, submitted_at = ?, score = ?, passed = ?, failed_critical = ? '
        'WHERE id = ? AND status = ?',
        [
          'submitted',
          now.millisecondsSinceEpoch,
          result.score,
          result.passed ? 1 : 0,
          result.criticalCorrect ? 0 : 1,
          session.id,
          _inProgress,
        ],
      );
      if (changed == 0) return null;
      for (var i = 0; i < session.paper.length; i++) {
        // unanswered counts as wrong and goes to "Câu sai" (FR-A40)
        await ProgressRepository.applyAnswer(
          txn,
          questionId: session.paper.questionIds[i],
          mode: AnswerMode.exam,
          selectedIndex: answers[i],
          isCorrect: result.correctByPosition[i] ?? false,
          at: now,
          sessionId: session.id,
        );
      }
      return result;
    });
  }

  /// Latest submitted result of each fixed set of [licenseClass] (FR-A20b): set number → (score, passed).
  Future<Map<int, ({int score, bool passed})>> latestFixedResults(
    String licenseClass,
  ) async {
    final rows = await _db.query(
      'exam_session',
      columns: ['fixed_set_no', 'score', 'passed'],
      where: 'license_class = ? AND status = ? AND fixed_set_no IS NOT NULL',
      whereArgs: [licenseClass, 'submitted'],
      orderBy: 'submitted_at, id',
    );
    return {
      for (final r in rows)
        r['fixed_set_no']! as int: (
          score: r['score']! as int,
          passed: r['passed'] == 1,
        ),
    };
  }

  /// Submitted tests of [licenseClass], newest first (FR-A29).
  Future<List<ExamHistoryEntry>> history(String licenseClass) async {
    final rows = await _db.query(
      'exam_session',
      columns: [
        'id',
        'fixed_set_no',
        'question_ids',
        'submitted_at',
        'score',
        'passed',
        'failed_critical',
      ],
      where: 'license_class = ? AND status = ?',
      whereArgs: [licenseClass, 'submitted'],
      orderBy: 'submitted_at DESC, id DESC',
    );
    return [
      for (final r in rows)
        ExamHistoryEntry(
          sessionId: r['id']! as int,
          fixedSetNo: r['fixed_set_no'] as int?,
          submittedAt: DateTime.fromMillisecondsSinceEpoch(
            r['submitted_at']! as int,
          ),
          score: r['score']! as int,
          total:
              ((jsonDecode(r['question_ids']! as String)
                          as Map<String, dynamic>)['questionIds']
                      as List)
                  .length,
          passed: r['passed'] == 1,
          failedCritical: r['failed_critical'] == 1,
        ),
    ];
  }

  /// Drops the unfinished test ("Không lưu và thoát", changing licence class).
  Future<void> abandon(int sessionId) => _db.update(
    'exam_session',
    {'status': 'abandoned'},
    where: 'id = ? AND status = ?',
    whereArgs: [sessionId, _inProgress],
  );
}

/// One submitted test in the history list (FR-A29).
class ExamHistoryEntry {
  const ExamHistoryEntry({
    required this.sessionId,
    required this.fixedSetNo,
    required this.submittedAt,
    required this.score,
    required this.total,
    required this.passed,
    required this.failedCritical,
  });

  final int sessionId;

  /// null = random test.
  final int? fixedSetNo;
  final DateTime submittedAt;
  final int score;
  final int total;
  final bool passed;
  final bool failedCritical;
}
