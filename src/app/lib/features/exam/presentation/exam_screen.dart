import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/question_view.dart';
import '../../home/data/home_summary_provider.dart';
import '../../stats/data/stats_providers.dart';
import '../../study/data/study_providers.dart';
import '../data/exam_providers.dart';
import '../domain/exam_session.dart';
import 'exam_exit_sheet.dart';

/// Taking a test (ST-08, ST-09): timer on the absolute deadline, answers saved before the screen changes,
/// question strip, exit choices, auto-submit at 00:00.
class ExamScreen extends ConsumerWidget {
  const ExamScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(examViewProvider(sessionId))) {
        AsyncData(value: final v?) => _ExamBody(
          key: ObjectKey(v.session.id),
          view: v,
        ),
        AsyncData() || AsyncError() => Scaffold(
          appBar: AppBar(title: const Text(S.practiceExam)),
          body: const Center(child: Text(S.examError)),
        ),
        _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
      };
}

class _ExamBody extends ConsumerStatefulWidget {
  const _ExamBody({super.key, required this.view});

  final ExamView view;

  @override
  ConsumerState<_ExamBody> createState() => _ExamBodyState();
}

class _ExamBodyState extends ConsumerState<_ExamBody> {
  late final ExamSession _session = widget.view.session;
  late final List<int?> _answers = [..._session.answers];
  final _pages = PageController();
  int _index = 0;
  late Duration _left = _session.remaining(_now());
  Timer? _ticker;
  bool _saving = false;
  bool _submitting = false;
  bool _sheetOpen = false;
  bool _allowPop = false;

  DateTime _now() => ref.read(clockProvider)();

  @override
  void initState() {
    super.initState();
    if (_session.status != ExamStatus.inProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
      return;
    }
    if (_left == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _submit(),
      ); // reopened after the deadline (FR-A25)
      return;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _tick() {
    final left = _session.remaining(_now());
    if (left != _left) setState(() => _left = left);
    if (left == Duration.zero) _timeUp();
  }

  void _timeUp() {
    _ticker?.cancel();
    if (_sheetOpen) {
      Navigator.of(context)
          .pop(); // close the exit sheet / dialog first (ST-09 AC1)
    }
    _submit();
  }

  /// FR-A24: the choice is written to the database first; only then does the screen show it.
  Future<void> _select(int option) async {
    if (_saving || _submitting) return;
    _saving = true;
    try {
      final repo = await ref.read(examSessionRepositoryProvider.future);
      await repo.saveAnswer(_session.id, _index, option);
      if (mounted) setState(() => _answers[_index] = option);
    } on StateError {
      // the test is no longer in progress (deadline passed / submitted elsewhere)
      if (mounted) await _submit();
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(S.saveAnswerFailed)));
      }
    } finally {
      _saving = false;
    }
  }

  /// Submits once (FR-A26); a second call or an already submitted test just opens the result.
  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;
    _ticker?.cancel();
    try {
      final repo = await ref.read(examSessionRepositoryProvider.future);
      await repo.submit(_session, widget.view.grade);
      ref
        ..invalidate(homeSummaryProvider)
        ..invalidate(topicListProvider)
        ..invalidate(fixedResultsProvider)
        ..invalidate(examHistoryProvider);
      _showResult();
    } on Exception {
      _submitting = false;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(S.examError)));
      }
    }
  }

  void _showResult() {
    if (!mounted) return;
    ref.invalidate(examViewProvider(_session.id));
    context.pushReplacement(Routes.examResult(_session.id));
  }

  Future<void> _openExitSheet() async {
    if (_submitting) return;
    _sheetOpen = true;
    final choice = await showExamExitSheet(
      context,
      unanswered: _answers.where((a) => a == null).length,
    );
    _sheetOpen = false;
    if (!mounted || _submitting) return;
    switch (choice) {
      case ExitChoice.submit:
        await _submit();
      case ExitChoice.saveAndExit:
        _leave();
      case ExitChoice.discard:
        final repo = await ref.read(examSessionRepositoryProvider.future);
        await repo.abandon(_session.id);
        ref.invalidate(homeSummaryProvider);
        _leave();
      case ExitChoice.keepGoing || null:
        break;
    }
  }

  void _leave() {
    _ticker?.cancel();
    ref.invalidate(homeSummaryProvider);
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.view.questions;
    final scheme = Theme.of(context).colorScheme;
    // amber under 2 minutes, red under 60 seconds (ST-09 AC1)
    final urgent = _left <= const Duration(seconds: 60);
    final warning = _left <= const Duration(minutes: 2);
    final timerBg = urgent
        ? scheme.errorContainer
        : (warning ? scheme.tertiaryContainer : scheme.secondaryContainer);
    final timerFg = urgent
        ? scheme.onErrorContainer
        : (warning ? scheme.onTertiaryContainer : scheme.onSecondaryContainer);
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _openExitSheet();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.questionOfTotal(_index + 1, questions.length)),
          actions: [
            Semantics(
              label: S.timeRemaining,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: timerBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: timerFg),
                    const SizedBox(width: 4),
                    Text(
                      S.timerLabel(_left),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: timerFg,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _QuestionStrip(
              answers: _answers,
              current: _index,
              onTap: (i) => _pages.jumpToPage(i),
            ),
            const Divider(height: 1),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: questions.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: QuestionView(
                    question: questions[i],
                    position: i + 1,
                    licenseClass: _session.paper.licenseClass,
                    mode: QuestionMode.exam,
                    selectedIndex: _answers[i],
                    onSelect: _select,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  child: FilledButton(
                    onPressed: _submitting ? null : _openExitSheet,
                    child: const Text(S.submit),
                  ),
                ),
                IconButton(
                  tooltip: S.nextQuestion,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _index == questions.length - 1
                      ? null
                      : () => _pages.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal strip of question numbers (FR-A22): answered / not answered / current.
class _QuestionStrip extends StatefulWidget {
  const _QuestionStrip({
    required this.answers,
    required this.current,
    required this.onTap,
  });

  final List<int?> answers;
  final int current;
  final ValueChanged<int> onTap;

  @override
  State<_QuestionStrip> createState() => _QuestionStripState();
}

/// Keeps the current question centred in the strip.
class _QuestionStripState extends State<_QuestionStrip> {
  static const _cell = 48.0; // touch target ≥ 48dp (NFR-07)
  static const _gap = 6.0;
  static const _pad = 12.0;
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_QuestionStrip old) {
    super.didUpdateWidget(old);
    if (old.current != widget.current) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centre());
    }
  }

  void _centre() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    final target =
        _pad +
        widget.current * (_cell + _gap) +
        _cell / 2 -
        p.viewportDimension / 2;
    _scroll.animateTo(
      target.clamp(p.minScrollExtent, p.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _pad, vertical: 8),
        itemCount: widget.answers.length,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, i) {
          final answered = widget.answers[i] != null;
          return Semantics(
            button: true,
            selected: i == widget.current,
            label:
                '${S.questionNumber(i + 1)}${answered ? '' : ', ${S.notAnswered}'}',
            excludeSemantics: true,
            child: Material(
              color: answered
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: i == widget.current
                    ? BorderSide(color: scheme.primary, width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () => widget.onTap(i),
                child: SizedBox(
                  width: _cell,
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: answered
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
