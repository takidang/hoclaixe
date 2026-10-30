import '../../../core/content/models.dart';
import '../../signs/domain/sign_search.dart';

/// Search over a class pool (search screen). Pure Dart. The text of every question is folded
/// (no case, no diacritics) once here, so each keystroke only compares strings.
class QuestionSearchIndex {
  QuestionSearchIndex(this.pool)
    : _folded = [
        // ' | ' keeps a query from matching across the end of one option and the start of the next
        for (final q in pool)
          foldForSearch([q.content, ...q.options].join(' | ')),
      ];

  final List<Question> pool;
  final List<String> _folded;

  /// A number ("120") finds the question with that official number first; words are matched in the
  /// question and its options, in official order. An empty query returns nothing.
  List<Question> search(String query) {
    final q = foldForSearch(query);
    if (q.isEmpty) return const [];
    final number = int.tryParse(q);
    return [
      for (final x in pool)
        if (x.number == number) x,
      for (var i = 0; i < pool.length; i++)
        if (pool[i].number != number && _folded[i].contains(q)) pool[i],
    ];
  }
}
