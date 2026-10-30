import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/stats/domain/daily_activity.dart';

void main() {
  final today = DateTime(2026, 11, 2, 21, 30);
  ({DateTime at, bool exam}) study(DateTime at) => (at: at, exam: false);
  ({DateTime at, bool exam}) exam(DateTime at) => (at: at, exam: true);

  group('dailyActivity', () {
    test(
      'đủ 30 ngày kể cả ngày không làm, cũ trước mới sau, ngày cuối là hôm nay',
      () {
        final days = dailyActivity(const [], today: today);
        expect(days, hasLength(30));
        expect(days.last.day, DateTime(2026, 11, 2));
        expect(
          days.first.day,
          DateTime(2026, 10, 4),
          reason: 'lùi qua tháng 10',
        );
        expect(days.every((d) => d.total == 0), isTrue);
      },
    );

    test(
      'đếm theo ngày giờ máy, tách học và thi thử; ngoài 30 ngày thì bỏ',
      () {
        final days = dailyActivity([
          study(DateTime(2026, 11, 2, 0, 1)),
          study(DateTime(2026, 11, 2, 23, 59)),
          exam(DateTime(2026, 11, 2, 8)),
          exam(DateTime(2026, 10, 31, 23, 59)),
          study(DateTime(2026, 10, 3, 12)), // 31 days ago
        ], today: today);
        expect([days.last.study, days.last.exam], [2, 1]);
        expect([days[27].day, days[27].exam], [DateTime(2026, 10, 31), 1]);
        expect(days.fold(0, (n, d) => n + d.total), 4);
      },
    );
  });

  group('studyStreak', () {
    List<DayActivity> active(List<int> totals) => [
      for (var i = 0; i < totals.length; i++)
        DayActivity(DateTime(2026, 10, 1 + i), study: totals[i], exam: 0),
    ];

    test('đếm các ngày liền nhau tới hôm nay', () {
      expect(studyStreak(active([1, 0, 3, 2, 5])), 3);
    });

    test('hôm nay chưa học thì vẫn giữ chuỗi tới hôm qua', () {
      expect(studyStreak(active([0, 4, 1, 0])), 2);
    });

    test('hôm qua và hôm nay đều trống → 0; danh sách rỗng → 0', () {
      expect(studyStreak(active([5, 0, 0])), 0);
      expect(studyStreak(const []), 0);
    });
  });
}
