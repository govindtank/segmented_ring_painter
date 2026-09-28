import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

void main() {
  group('SegmentedRingPainter & Widget Tests', () {
    test('RingSegment copyWith and equality', () {
      const seg1 = RingSegment(value: 30, color: Colors.blue, label: 'Water');
      final seg2 = seg1.copyWith(value: 45);
      final seg3 = seg1.copyWith();

      expect(seg1.value, 30);
      expect(seg2.value, 45);
      expect(seg1, equals(seg3));
      expect(seg1.hashCode, equals(seg3.hashCode));
      expect(seg1, isNot(equals(seg2)));
      expect(seg1.toString(), contains('Water'));
    });

    test('SegmentedRingStyle copyWith and equality', () {
      const style1 = SegmentedRingStyle(strokeWidth: 15, gapAngle: 6);
      final style2 = style1.copyWith(strokeWidth: 20);
      final style3 = style1.copyWith();

      expect(style1, equals(style3));
      expect(style1, isNot(equals(style2)));
      expect(style2.strokeWidth, 20);
    });

    test('SegmentedRingPainter shouldRepaint triggers accurately', () {
      const segsA = [RingSegment(value: 10, color: Colors.red)];
      const segsB = [RingSegment(value: 20, color: Colors.blue)];

      final painter1 =
          SegmentedRingPainter(segments: segsA, animationProgress: 1.0);
      final painter2 =
          SegmentedRingPainter(segments: segsA, animationProgress: 1.0);
      final painter3 =
          SegmentedRingPainter(segments: segsB, animationProgress: 1.0);
      final painter4 =
          SegmentedRingPainter(segments: segsA, animationProgress: 0.5);

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painter3), isTrue);
      expect(painter1.shouldRepaint(painter4), isTrue);
    });

    testWidgets('SegmentedRingChart renders properly and handles tap',
        (WidgetTester tester) async {
      int? tappedIndex;
      RingSegment? tappedSeg;

      final segments = [
        const RingSegment(value: 40, color: Colors.red, label: 'RedSeg'),
        const RingSegment(value: 60, color: Colors.blue, label: 'BlueSeg'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SegmentedRingChart(
                width: 200,
                height: 200,
                segments: segments,
                style: const SegmentedRingStyle(
                  strokeWidth: 20,
                  gapAngle: 0,
                  startAngle: 0,
                ),
                center: const Text('Total: 100'),
                onSegmentTap: (index, seg) {
                  tappedIndex = index;
                  tappedSeg = seg;
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial frame
      await tester.pumpAndSettle();
      expect(find.text('Total: 100'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Tap on the right side of the ring (0 radians -> index 0)
      // Center of 200x200 widget in scaffold
      final ringCenter = tester.getCenter(find.byType(SegmentedRingChart));
      // Tap at center + (90, 0)
      await tester.tapAt(ringCenter + const Offset(90, 0));
      await tester.pumpAndSettle();

      expect(tappedIndex, 0);
      expect(tappedSeg?.label, 'RedSeg');
    });
  });
}
