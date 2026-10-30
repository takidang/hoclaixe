import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../content/models.dart';
import '../strings.dart';

/// Reads a question aloud with the device's text-to-speech engine ("Đọc câu hỏi").
/// An interface so widget tests replace the platform plugin with a fake.
abstract class QuestionReader {
  /// Starts reading [text]; [onDone] runs when reading ends or is stopped.
  /// Throws [SpeechUnavailable] when the device has no Vietnamese voice.
  Future<void> speak(String text, {required VoidCallback onDone});

  Future<void> stop();
}

class SpeechUnavailable implements Exception {
  const SpeechUnavailable();
}

/// What is read: position, question, then every option with its number, as on screen.
String speechTextOf(Question q, int position) => [
  '${S.questionNumber(position)}.',
  q.content,
  for (var i = 0; i < q.options.length; i++)
    '${S.answerLabel(i + 1)}. ${q.options[i]}',
].join('\n');

class TtsQuestionReader implements QuestionReader {
  static const _language = 'vi-VN';

  FlutterTts? _tts;
  VoidCallback? _onDone;

  Future<FlutterTts> _engine() async {
    final existing = _tts;
    if (existing != null) return existing;
    final tts = FlutterTts();
    void done() {
      final cb = _onDone;
      _onDone = null;
      cb?.call();
    }

    tts
      ..setCompletionHandler(done)
      ..setCancelHandler(done)
      ..setErrorHandler((_) => done());
    return _tts = tts;
  }

  @override
  Future<void> speak(String text, {required VoidCallback onDone}) async {
    final tts = await _engine();
    // web and some Android engines answer null/1 instead of true; only an explicit false means "no voice"
    if (await tts.isLanguageAvailable(_language) == false) {
      throw const SpeechUnavailable();
    }
    await tts.setLanguage(_language);
    await tts.setSpeechRate(
      0.5,
    ); // engine scale 0–1: 0.5 is a normal pace on Android
    _onDone = onDone;
    await tts.speak(text);
  }

  @override
  Future<void> stop() async {
    final tts = _tts;
    if (tts == null) return; // never started: do not wake the plugin
    await tts.stop();
  }
}

final questionReaderProvider = Provider<QuestionReader>(
  (ref) => TtsQuestionReader(),
);
