import '../../../core/content/models.dart';

/// Questions a licence class studies and is tested on (CV 2262 §I.2), sorted by number.
/// [pool] is the blueprint's pool name when it differs from the class (e.g. A shares A1's 250 questions).
List<Question> questionPool(
  List<Question> bank,
  String licenseClass, {
  String? pool,
}) =>
    bank.where((q) => q.inPool(pool ?? licenseClass)).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
