/// Answers given on one day: while studying or reviewing, and in practice tests. Pure Dart.
class DayActivity {
  const DayActivity(this.day, {required this.study, required this.exam});

  /// Local midnight.
  final DateTime day;
  final int study;
  final int exam;

  int get total => study + exam;
}

/// One entry per day for the [days] days ending [today], oldest first, including days with nothing.
/// [answers]: when each answer was given and whether it was in a practice test.
List<DayActivity> dailyActivity(
  Iterable<({DateTime at, bool exam})> answers, {
  required DateTime today,
  int days = 30,
}) {
  DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);
  // DateTime(y, m, d ± n) rolls over months and years by itself
  DateTime nth(int i) =>
      DateTime(today.year, today.month, today.day - (days - 1) + i);
  final study = <DateTime, int>{};
  final exam = <DateTime, int>{};
  for (final a in answers) {
    (a.exam ? exam : study).update(
      dayOf(a.at),
      (n) => n + 1,
      ifAbsent: () => 1,
    );
  }
  return [
    for (var i = 0; i < days; i++)
      DayActivity(nth(i), study: study[nth(i)] ?? 0, exam: exam[nth(i)] ?? 0),
  ];
}

/// Days in a row with at least one answer, ending today, or yesterday when nothing has been done yet today
/// (the streak is not lost before the day's study). Counted within [days] only.
int studyStreak(List<DayActivity> days) {
  var i = days.length - 1;
  if (i >= 0 && days[i].total == 0) i--;
  var n = 0;
  for (; i >= 0 && days[i].total > 0; i--) {
    n++;
  }
  return n;
}
