import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/features/signs/domain/sign_search.dart';

import '../../../support/real_content.dart';

void main() {
  final signs = loadRealContent().signs;

  test('bỏ dấu, chữ thường, bỏ dấu chấm và khoảng trắng thừa', () {
    expect(foldForSearch('Cấm  QUAY đầu xe'), 'cam quay dau xe');
    expect(foldForSearch('Đường cấm'), 'duong cam');
    expect(foldForSearch('P.124a'), 'p124a');
  });

  test('tìm theo mã: "P.124" và "p124" cho cùng kết quả, đều là biển P.124… (FR-A31)', () {
    final a = searchSigns(signs, 'P.124');
    expect(a, isNotEmpty);
    expect(a.every((s) => s.code.startsWith('P.124')), isTrue);
    expect(searchSigns(signs, 'p124').map((s) => s.code), a.map((s) => s.code));
  });

  test('tìm theo tên có dấu hoặc không dấu: "quay đầu" = "quay dau"', () {
    final withMarks = searchSigns(signs, 'quay đầu');
    expect(withMarks.map((s) => s.code), contains('P.124a'));
    expect(
      searchSigns(signs, 'QUAY DAU').map((s) => s.code),
      withMarks.map((s) => s.code),
    );
  });

  test('chuỗi rỗng không trả kết quả; chuỗi lạ trả rỗng', () {
    expect(searchSigns(signs, '  '), isEmpty);
    expect(searchSigns(signs, 'zzzz'), isEmpty);
  });
}
