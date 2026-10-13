import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// Loads the bundled read-only content (ADR-003) once; parsing runs in a background isolate.
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _files = {
    'questions': 'assets/data/questions.json',
    'structures': 'assets/data/exam-structures.json',
    'signs': 'assets/data/signs.json',
    'version': 'assets/data/content_version.json',
  };

  Future<ContentBundle> load() async {
    final raw = <String, String>{
      for (final e in _files.entries)
        e.key: await _bundle.loadString(e.value, cache: false),
    };
    return compute(_decodeAndParse, raw);
  }
}

ContentBundle _decodeAndParse(Map<String, String> raw) =>
    parseContent({for (final e in raw.entries) e.key: jsonDecode(e.value)});
