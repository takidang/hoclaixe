import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoclaixe/shared/widgets/motion.dart';

void main() {
  Widget host(Widget child, {bool reduce = false, bool ambient = true}) =>
      ProviderScope(
        overrides: [ambientMotionProvider.overrideWithValue(ambient)],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: Center(child: SizedBox.square(dimension: 200, child: child)),
          ),
        ),
      );

  double scaleOf(WidgetTester tester) {
    final t = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(KenBurns),
            matching: find.byType(Transform),
          )
          .last,
    );
    return t.transform.getMaxScaleOnAxis();
  }

  testWidgets('ảnh "thở": phóng to dần theo thời gian', (tester) async {
    await tester.pumpWidget(
      host(const KenBurns(child: ColoredBox(color: Colors.red))),
    );
    final start = scaleOf(tester);
    await tester.pump(const Duration(seconds: 7));
    expect(scaleOf(tester), greaterThan(start));
  });

  testWidgets(
    'máy bật "giảm chuyển động" (hoặc tắt chuyển động nền) → ảnh đứng yên',
    (tester) async {
      for (final (reduce, ambient) in [(true, true), (false, false)]) {
        await tester.pumpWidget(
          host(
            KenBurns(
              key: UniqueKey(),
              child: const ColoredBox(color: Colors.red),
            ),
            reduce: reduce,
            ambient: ambient,
          ),
        );
        final start = scaleOf(tester);
        await tester.pump(const Duration(seconds: 7));
        expect(
          scaleOf(tester),
          start,
          reason: 'reduce=$reduce ambient=$ambient',
        );
      }
    },
  );

  testWidgets('nhấn giữ thì thu nhỏ còn 97 %, thả ra thì trở lại', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const PressScale(child: ColoredBox(color: Colors.blue))),
    );
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressScale)),
    );
    await tester.pump();
    expect(scale(), 0.97);
    await gesture.up();
    await tester.pump();
    expect(scale(), 1);
  });

  testWidgets('số đếm tăng dần rồi dừng đúng giá trị', (tester) async {
    await tester.pumpWidget(
      host(CountUp(value: 79, builder: (context, n) => Text('$n'))),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final mid = int.parse(tester.widget<Text>(find.byType(Text)).data!);
    expect(mid, inExclusiveRange(0, 79));
    await tester.pumpAndSettle();
    expect(find.text('79'), findsOneWidget);
  });
}
