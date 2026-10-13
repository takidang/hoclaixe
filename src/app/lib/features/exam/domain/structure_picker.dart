import '../../../core/content/models.dart';

class StructureChoice {
  const StructureChoice(this.structure, {required this.outdated});

  final ExamStructure structure;

  /// True when no complete structure covers the date and an older one is used (show a warning, BR-08).
  final bool outdated;
}

/// Picks the test blueprint for a licence class on a given day (BR-08).
abstract final class StructurePicker {
  static StructureChoice? pick(
    List<ExamStructure> all,
    String licenseClass,
    DateTime now,
  ) {
    final usable =
        all.where((s) => s.licenseClass == licenseClass && s.complete).toList()
          ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
    if (usable.isEmpty) return null;

    final day = DateTime(now.year, now.month, now.day);
    bool covers(ExamStructure s) =>
        !day.isBefore(s.effectiveFrom) &&
        (s.effectiveTo == null || !day.isAfter(s.effectiveTo!));

    for (final s in usable.reversed) {
      if (covers(s)) return StructureChoice(s, outdated: false);
    }
    // Nothing complete covers today (e.g. after 01/03/2027 before a new question bank exists).
    final started = usable
        .where((s) => !day.isBefore(s.effectiveFrom))
        .toList();
    return StructureChoice(
      started.isNotEmpty ? started.last : usable.first,
      outdated: true,
    );
  }
}
