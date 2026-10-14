import 'dart:convert';
import 'dart:io';

import 'package:hoclaixe/core/content/models.dart';

/// The real bundled content (assets/data), read from disk for tests that must run on official data.
ContentBundle loadRealContent() {
  Map<String, dynamic> read(String name) =>
      jsonDecode(File('assets/data/$name').readAsStringSync())
          as Map<String, dynamic>;
  return parseContent({
    'questions': read('questions.json'),
    'structures': read('exam-structures.json'),
    'signs': read('signs.json'),
    'version': read('content_version.json'),
  });
}
