import '../../../core/content/models.dart';
import '../../signs/domain/sign_search.dart';

/// Questions matching [query] in the class pool, in official order (search screen). Pure Dart.
///
/// A number ("120") finds the question with that official number first; words are matched in the
/// question and its options, ignoring case and Vietnamese diacritics. An empty query returns nothing.
List<Question> searchQuestions(List<Question> pool, String query) {
  final q = foldForSearch(query);
  if (q.isEmpty) return const [];
  final number = int.tryParse(q);
  final byNumber = [
    for (final x in pool)
      if (x.number == number) x,
  ];
  final byText = [
    for (final x in pool)
      if (x.number != number &&
          (foldForSearch(x.content).contains(q) ||
              x.options.any((o) => foldForSearch(o).contains(q))))
        x,
  ];
  return [...byNumber, ...byText];
}
