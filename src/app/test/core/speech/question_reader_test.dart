import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/core/speech/question_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late bool voice;

  setUp(() {
    voice = true;
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => call.method == 'isLanguageAvailable' ? voice : 1,
    );
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  /// An event the text-to-speech engine sends to the app.
  Future<void> engine(String event) => messenger.handlePlatformMessage(
    channel.name,
    const StandardMethodCodec().encodeMethodCall(MethodCall(event, true)),
    (_) {},
  );

  test('dừng câu cũ rồi đọc câu mới: tín hiệu "đã dừng" đến muộn không tắt nút của câu mới', () async {
    final reader = TtsQuestionReader();
    var firstDone = 0;
    var secondDone = 0;
    await reader.speak('câu 1', onDone: () => firstDone++);
    await reader.stop();
    await reader.speak('câu 2', onDone: () => secondDone++);

    await engine(
      'speak.onCancel',
    ); // Android: end of the stopped "câu 1", after "câu 2" started
    expect([firstDone, secondDone], [0, 0]);

    await engine('speak.onComplete'); // "câu 2" read to the end
    expect([firstDone, secondDone], [0, 1]);
  });

  test(
    'web: câu cũ kết thúc bằng lỗi "interrupted" cũng không tắt nhầm',
    () async {
      final reader = TtsQuestionReader();
      var done = 0;
      await reader.speak('câu 1', onDone: () {});
      await reader.stop();
      await reader.speak('câu 2', onDone: () => done++);
      await engine('speak.onError');
      expect(done, 0);
      await engine('speak.onComplete');
      expect(done, 1);
    },
  );

  test(
    'máy không có giọng tiếng Việt → SpeechUnavailable, không đọc',
    () async {
      voice = false;
      expect(
        () => TtsQuestionReader().speak('câu 1', onDone: () {}),
        throwsA(isA<SpeechUnavailable>()),
      );
    },
  );
}
