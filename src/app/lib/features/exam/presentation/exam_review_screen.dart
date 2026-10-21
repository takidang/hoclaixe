import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/strings.dart';
import '../../../shared/widgets/question_view.dart';
import '../data/exam_providers.dart';

/// Review of a submitted test (ST-10 AC2): chosen answer, correct answer and critical badge per question;
/// filter "Chỉ câu sai" (wrong or unanswered).
class ExamReviewScreen extends ConsumerStatefulWidget {
  const ExamReviewScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends ConsumerState<ExamReviewScreen> {
  bool _onlyWrong = false;

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(examViewProvider(widget.sessionId)).value;
    return Scaffold(
      appBar: AppBar(title: const Text(S.reviewTest)),
      body: view == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final answers = view.session.answers;
                final positions = [
                  for (var i = 0; i < view.questions.length; i++)
                    if (!_onlyWrong ||
                        answers[i] != view.questions[i].correctIndex)
                      i,
                ];
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: positions.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 32),
                  itemBuilder: (context, k) {
                    if (k == 0) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FilterChip(
                          label: const Text(S.onlyWrong),
                          selected: _onlyWrong,
                          onSelected: (v) => setState(() => _onlyWrong = v),
                        ),
                      );
                    }
                    final i = positions[k - 1];
                    return QuestionView(
                      question: view.questions[i],
                      position: i + 1,
                      licenseClass: view.session.paper.licenseClass,
                      mode: QuestionMode.review,
                      selectedIndex: answers[i],
                    );
                  },
                );
              },
            ),
    );
  }
}
