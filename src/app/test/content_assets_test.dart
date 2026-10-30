import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/content/models.dart';

import 'support/real_content.dart';

/// Guards ADR-003: the bundled assets are exactly what tools/sync_assets.py wrote from the validated data/.
void main() {
  Map<String, dynamic> readJson(String name) =>
      jsonDecode(File('assets/data/$name').readAsStringSync())
          as Map<String, dynamic>;

  test('content_version.json hashes match the bundled JSON files (sync not forgotten)', () {
    final hashes =
        readJson('content_version.json')['sha256'] as Map<String, dynamic>;
    for (final entry in hashes.entries) {
      final actual = sha256
          .convert(File('assets/data/${entry.key}').readAsBytesSync())
          .toString();
      expect(
        actual,
        entry.value,
        reason: '${entry.key} changed — run python tools/sync_assets.py',
      );
    }
  });

  test('content parses and matches the official counts (CV 2262/CSGT-P5)', () {
    final c = parseContent({
      'questions': readJson('questions.json'),
      'structures': readJson('exam-structures.json'),
      'signs': readJson('signs.json'),
      'version': readJson('content_version.json'),
    });
    expect(c.questions, hasLength(600));
    expect(c.questions.where((q) => q.isCriticalFor('B')), hasLength(60));
    expect(c.questions.where((q) => q.inPool('A1')), hasLength(250));
    expect(c.questions.where((q) => q.isCriticalFor('A1')), hasLength(20));
    for (final q in c.questions) {
      expect(
        q.correctIndex,
        inInclusiveRange(0, q.options.length - 1),
        reason: q.id,
      );
      for (final img in q.images) {
        expect(File(img).existsSync(), isTrue, reason: '${q.id}: missing $img');
      }
    }
    final b = c.structures.firstWhere((s) => s.id == 'B-2025');
    expect([b.questionCount, b.durationMinutes, b.passScore], [30, 20, 27]);
    expect(c.signs, isNotEmpty);
  });

  test('P.127 chỉ có hình biển (Hình B.27b trang 90), không có mảnh toán đồ Hình B.27a', () {
    final p127 = loadRealContent().signs.singleWhere((s) => s.code == 'P.127');
    expect(p127.images, hasLength(1));
  });
}
