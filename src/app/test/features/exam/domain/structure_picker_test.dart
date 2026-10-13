import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/exam/domain/seeded_random.dart';
import 'package:hoclaixe/features/exam/domain/structure_picker.dart';

import '../../../support/real_content.dart';

void main() {
  final structures = loadRealContent().structures;

  test(
    'trong thời gian hiệu lực TT 12/2025 → cấu trúc 2025, không cảnh báo',
    () {
      final c = StructurePicker.pick(structures, 'B', DateTime(2026, 10, 13))!;
      expect(c.structure.id, 'B-2025');
      expect(c.outdated, isFalse);
    },
  );

  test('ngày cuối hiệu lực 28/02/2027 vẫn là cấu trúc 2025', () {
    final c = StructurePicker.pick(
      structures,
      'A1',
      DateTime(2027, 2, 28, 23, 59),
    )!;
    expect([c.structure.id, c.outdated], ['A1-2025', false]);
  });

  test(
    'từ 01/3/2027 khi cấu trúc mới chưa đủ → dùng 2025 kèm cảnh báo (BR-08)',
    () {
      final c = StructurePicker.pick(structures, 'B', DateTime(2027, 3, 1))!;
      expect([c.structure.id, c.outdated], ['B-2025', true]);
    },
  );

  test('hạng chưa hỗ trợ → không có cấu trúc', () {
    expect(
      StructurePicker.pick(structures, 'C', DateTime(2026, 10, 13)),
      isNull,
    );
  });

  test('SeededRandom và stableHash cho kết quả cố định (đề cố định không đổi qua các bản cập nhật)', () {
    expect(stableHash('B|1|v'), stableHash('B|1|v'));
    expect(stableHash('B|1|v'), isNot(stableHash('B|2|v')));
    final a = SeededRandom(123);
    final b = SeededRandom(123);
    expect(
      [for (var i = 0; i < 5; i++) a.nextInt(600)],
      [for (var i = 0; i < 5; i++) b.nextInt(600)],
    );
    // golden values: if these change, every fixed test set changes — do not update without a decision
    expect(stableHash('hoclaixe'), 0x089C991A); // cross-checked with an independent Python FNV-1a
  });
}
