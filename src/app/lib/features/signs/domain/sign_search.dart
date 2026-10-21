import '../../../core/content/models.dart';

const _from =
    'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ';
const _to =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

/// Lower case, without Vietnamese diacritics, without dots and extra spaces — "Cấm  quay đầu" → "cam quay dau",
/// "P.124a" → "p124a". Pure Dart (FR-A31).
String foldForSearch(String text) {
  final buf = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    final i = _from.indexOf(ch);
    buf.write(i < 0 ? ch : _to[i]);
  }
  return buf
      .toString()
      .replaceAll('.', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Signs whose code or name contains [query] (ignoring case, diacritics and dots), in catalog order.
/// An empty query returns nothing.
List<TrafficSign> searchSigns(List<TrafficSign> signs, String query) {
  final q = foldForSearch(query);
  if (q.isEmpty) return const [];
  return [
    for (final s in signs)
      if (foldForSearch(s.code).contains(q) ||
          foldForSearch(s.name).contains(q))
        s,
  ];
}
