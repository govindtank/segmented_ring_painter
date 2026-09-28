import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

void main() {
  group('NestedActivityRings Tests', () {
    test('NestedRing model calculations', () {
      const ring1 = NestedRing(
        value: 400,
        maxValue: 500,
        color: Colors.red,
        label: 'Move',
      );

      expect(ring1.progress, closeTo(0.8, 1e-6));
      expect(ring1.isCompleted, isFalse);

      final overachieved = ring1.copyWith(value: 600);
      expect(overachieved.progress, closeTo(1.2, 1e-6));
      expect(overachieved.isCompleted, isTrue);
      expect(overachieved.toString(), contains('Move'));
    });

    test('NestedRingsStyle copyWith and equality', () {
      const style1 = NestedRingsStyle(strokeWidth: 20, ringSpacing: 4);
      final style2 = style1.copyWith(strokeWidth: 28);
      final style3 = style1.copyWith();

      expect(style1, equals(style3));
      expect(style1, isNot(equals(style2)));
      expect(style2.strokeWidth, 28);
    });

    test('NestedRingPainter shouldRepaint triggers correctly', () {
      const ringsA = [NestedRing(value: 50, maxValue: 100, color: Colors.red)];
      const ringsB = [NestedRing(value: 80, maxValue: 100, color: Colors.blue)];

      const painter1 = NestedRingPainter(rings: ringsA, animationProgress: 1.0);
      const painter2 = NestedRingPainter(rings: ringsA, animationProgress: 1.0);
      const painter3 = NestedRingPainter(rings: ringsB, animationProgress: 1.0);
      const painter4 = NestedRingPainter(rings: ringsA, animationProgress: 0.5);

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
      expect(painter1.shouldRepaint(painter4), isTrue);
    });

    testWidgets('NestedActivityRings widget renders and detects tap on ring',
        (WidgetTester tester) async {
      int? tappedRingIndex;
      NestedRing? tappedRing;

      final rings = [
        const NestedRing(
            value: 450, maxValue: 600, color: Colors.red, label: 'Move'),
        const NestedRing(
            value: 30, maxValue: 30, color: Colors.green, label: 'Exercise'),
        const NestedRing(
            value: 8, maxValue: 12, color: Colors.cyan, label: 'Stand'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NestedActivityRings(
                width: 200,
                height: 200,
                rings: rings,
                style: const NestedRingsStyle(
                  strokeWidth: 20,
                  ringSpacing: 4,
                  startAngle: -90,
                ),
                center: const Icon(Icons.favorite,
                    color: Colors.redAccent, size: 36),
                onRingTap: (index, ring) {
                  tappedRingIndex = index;
                  tappedRing = ring;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      final ringCenter = tester.getCenter(find.byType(NestedActivityRings));
      // Outer ring radius is 90. Tap at center + (90, 0)
      await tester.tapAt(ringCenter + const Offset(90, 0));
      await tester.pumpAndSettle();

      expect(tappedRingIndex, 0);
      expect(tappedRing?.label, 'Move');
    });
  });
}
