import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/question_view.dart';
import '../data/study_providers.dart';
import '../domain/study_topic.dart';
import 'question_grid_sheet.dart';
import 'topic_summary_sheet.dart';
import 'topic_title.dart';

/// Studies one topic question by question (UC-03, FR-A11, FR-A13). Also used for wrong-list review.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataProvider(topicId));
    final chapters = ref.watch(contentProvider).value?.chapters ?? const {};
    return switch (data) {
      AsyncData(value: final d?) => _StudyBody(
        key: ObjectKey(d),
        data: d,
        title: topicTitle(d.topic, chapters),
      ),
      AsyncData() => const _Message(S.topicNotFound),
      AsyncError() => const _Message(S.studyError),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.title = S.studyByTopic});

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    ),
  );
}

class _StudyBody extends ConsumerStatefulWidget {
  const _StudyBody({super.key, required this.data, required this.title});

  final StudyData data;
  final String title;

  @override
  ConsumerState<_StudyBody> createState() => _StudyBodyState();
}

class _StudyBodyState extends ConsumerState<_StudyBody> {
  late final PageController _pages = PageController(
    initialPage: widget.data.startIndex,
  );
  late final Map<String, int> _answers = {...widget.data.answers};
  late int _index = widget.data.startIndex;

  StudyTopic get _topic => widget.data.topic;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _onPageChanged(int i) async {
    setState(() => _index = i);
    if (_topic.isSnapshot) return;
    final repo = await ref.read(progressRepositoryProvider.future);
    await repo.saveTopicPosition(
      widget.data.licenseClass,
      _topic.id,
      _topic.questions[i].id,
    );
  }

  Future<void> _onSelect(int option) async {
    final q = _topic.questions[_index];
    if (_answers.containsKey(q.id)) return; // locked (FR-A11)
    setState(() => _answers[q.id] = option);
    try {
      final repo = await ref.read(progressRepositoryProvider.future);
      await repo.recordAnswer(
        questionId: q.id,
        mode: answerModeOf(_topic),
        selectedIndex: option,
        isCorrect: option == q.correctIndex,
      );
    } on Exception {
      if (!mounted) return;
      setState(() => _answers.remove(q.id));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(S.saveAnswerFailed)));
      return;
    }
    if (!mounted) return;
    invalidateProgressViews(ref);
    if (RoundSummary.of(_topic, _answers).finished) await _showSummary();
  }

  void _goTo(int i) => _pages.jumpToPage(i);

  Future<void> _next() async {
    if (_index < _topic.questions.length - 1) {
      await _pages.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else if (RoundSummary.of(_topic, _answers).finished) {
      await _showSummary();
    }
  }

  Future<void> _openGrid() async {
    final cells = [
      for (final q in _topic.questions)
        switch (_answers[q.id]) {
          null => GridCell.notAnswered,
          final a when a == q.correctIndex => GridCell.correct,
          _ => GridCell.wrong,
        },
    ];
    final chosen = await showQuestionGrid(
      context,
      cells: cells,
      current: _index,
    );
    if (chosen != null) _goTo(chosen);
  }

  Future<void> _restart() async {
    final repo = await ref.read(progressRepositoryProvider.future);
    await repo.restartRound(widget.data.licenseClass, _topic.id);
    await repo.saveTopicPosition(
      widget.data.licenseClass,
      _topic.id,
      _topic.questions.first.id,
    );
    ref.invalidate(
      studyDataProvider(_topic.id),
    ); // rebuilds this screen from the new round
  }

  Future<void> _showSummary() async {
    final action = await showTopicSummary(
      context,
      summary: RoundSummary.of(_topic, _answers),
      canRestart: !_topic.isSnapshot,
      reviewLabel: _topic.isWrongList
          ? S.reviewRemainingWrong
          : S.reviewTopicWrong,
      alwaysOfferReview: _topic.isWrongList,
    );
    if (!mounted) return;
    switch (action) {
      case SummaryAction.reviewWrong:
        if (_topic.isWrongList) {
          ref.invalidate(
            studyDataProvider(_topic.id),
          ); // new snapshot of what is still wrong
        } else {
          await context.push(Routes.studyTopic(StudyTopic.wrongOf(_topic.id)));
        }
      case SummaryAction.restart:
        await _restart();
      case SummaryAction.back:
        context.pop();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _topic.questions;
    if (questions.isEmpty) {
      if (_topic.id == StudyTopic.wrongOf(StudyTopic.allId) ||
          _topic.kind == TopicKind.frequent) {
        return _NoWrongYet(title: widget.title);
      }
      return _Message(
        _topic.isWrongList ? S.noWrongInTopic : S.emptyTopic,
        title: widget.title,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          if (!_topic.isSnapshot)
            IconButton(
              tooltip: S.restartTopic,
              icon: const Icon(Icons.restart_alt),
              onPressed: _confirmRestart,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pages,
        itemCount: questions.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, i) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: QuestionView(
            question: questions[i],
            position: i + 1,
            licenseClass: widget.data.licenseClass,
            mode: QuestionMode.study,
            selectedIndex: _answers[questions[i].id],
            onSelect: _onSelect,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: S.previousQuestion,
                icon: const Icon(Icons.chevron_left),
                onPressed: _index == 0
                    ? null
                    : () => _pages.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _openGrid,
                  icon: const Icon(Icons.grid_view),
                  label: Text(S.questionOfTotal(_index + 1, questions.length)),
                ),
              ),
              IconButton(
                tooltip: S.nextQuestion,
                icon: const Icon(Icons.chevron_right),
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRestart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.restartTopic),
        content: const Text(S.restartTopicHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(S.restartTopic),
          ),
        ],
      ),
    );
    if (ok == true) await _restart();
  }
}

/// Empty wrong list of the whole class (ST-07 AC2).
class _NoWrongYet extends StatelessWidget {
  const _NoWrongYet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.noWrongYet,
                style: text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                S.noWrongYetHint,
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pushReplacement(Routes.exam),
                child: const Text(S.practiceExam),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
