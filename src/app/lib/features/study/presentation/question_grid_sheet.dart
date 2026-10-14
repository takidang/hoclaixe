import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';

/// State of one cell in the question grid.
enum GridCell { notAnswered, correct, wrong }

/// Bottom sheet listing every question of the topic (FR-A13). Returns the chosen index.
Future<int?> showQuestionGrid(
  BuildContext context, {
  required List<GridCell> cells,
  required int current,
}) => showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _QuestionGrid(cells: cells, current: current),
);

class _QuestionGrid extends StatelessWidget {
  const _QuestionGrid({required this.cells, required this.current});

  final List<GridCell> cells;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answer = AnswerColors.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.chooseQuestion,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 56,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: cells.length,
                itemBuilder: (context, i) {
                  final (
                    Color background,
                    Color foreground,
                  ) = switch (cells[i]) {
                    GridCell.correct => (
                      answer.correctContainer,
                      answer.correct,
                    ),
                    GridCell.wrong => (answer.wrongContainer, answer.wrong),
                    GridCell.notAnswered => (
                      scheme.surfaceContainerHighest,
                      scheme.onSurface,
                    ),
                  };
                  return Material(
                    color: background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: i == current
                          ? BorderSide(color: scheme.primary, width: 2)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () => Navigator.pop(context, i),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: foreground),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
