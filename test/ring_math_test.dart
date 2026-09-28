import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

void main() {
  group('RingMath Unit Tests', () {
    test('degreesToRadians and radiansToDegrees conversions', () {
      expect(RingMath.degreesToRadians(180.0), closeTo(math.pi, 1e-6));
      expect(RingMath.degreesToRadians(360.0), closeTo(2 * math.pi, 1e-6));
      expect(RingMath.degreesToRadians(-90.0), closeTo(-math.pi / 2, 1e-6));

      expect(RingMath.radiansToDegrees(math.pi), closeTo(180.0, 1e-6));
      expect(RingMath.radiansToDegrees(2 * math.pi), closeTo(360.0, 1e-6));
    });

    test('normalizeRadians maps angles into [0, 2*pi)', () {
      expect(RingMath.normalizeRadians(0), closeTo(0, 1e-6));
      expect(RingMath.normalizeRadians(2 * math.pi), closeTo(0, 1e-6));
      expect(RingMath.normalizeRadians(-math.pi / 2),
          closeTo(1.5 * math.pi, 1e-6));
      expect(RingMath.normalizeRadians(3 * math.pi), closeTo(math.pi, 1e-6));
    });

    test('calculateSegmentArcs proportional mode with gaps', () {
      final segments = [
        const RingSegment(value: 50, color: Colors.red),
        const RingSegment(value: 50, color: Colors.blue),
      ];

      final arcs = RingMath.calculateSegmentArcs(
        segments: segments,
        startAngleRad: 0,
        gapAngleRad: RingMath.degreesToRadians(10),
        animationProgress: 1.0,
      );

      expect(arcs.length, 2);
      expect(arcs[0].index, 0);
      expect(arcs[1].index, 1);

      // Usable sweep = 2pi - 2 * 10 deg (in rad)
      final double totalGapRad = 2 * RingMath.degreesToRadians(10);
      final double usableSweep = 2 * math.pi - totalGapRad;
      final double expectedSweepPerSegment = usableSweep / 2;

      expect(arcs[0].sweepAngle, closeTo(expectedSweepPerSegment, 1e-5));
      expect(arcs[1].sweepAngle, closeTo(expectedSweepPerSegment, 1e-5));
    });

    test('isAngleInsideArc accurately detects angle inside sweep', () {
      // Arc from 0 to pi/2 (first quadrant)
      expect(RingMath.isAngleInsideArc(math.pi / 4, 0, math.pi / 2), isTrue);
      expect(RingMath.isAngleInsideArc(math.pi, 0, math.pi / 2), isFalse);

      // Arc crossing 0 boundary (e.g. 350 deg to 30 deg -> 1.94pi to 0.16pi)
      final double start = RingMath.degreesToRadians(350);
      final double sweep = RingMath.degreesToRadians(40);
      expect(
          RingMath.isAngleInsideArc(
              RingMath.degreesToRadians(355), start, sweep),
          isTrue);
      expect(
          RingMath.isAngleInsideArc(
              RingMath.degreesToRadians(10), start, sweep),
          isTrue);
      expect(
          RingMath.isAngleInsideArc(
              RingMath.degreesToRadians(180), start, sweep),
          isFalse);
    });

    test('hitTestSegment detects tap inside ring radius and angular segment',
        () {
      final segments = [
        const RingSegment(value: 50, color: Colors.red),
        const RingSegment(value: 50, color: Colors.blue),
      ];

      final arcs = RingMath.calculateSegmentArcs(
        segments: segments,
        startAngleRad: 0,
        gapAngleRad: 0,
        animationProgress: 1.0,
      );

      const size = Size(200, 200);
      const strokeWidth = 20.0;
      // Center is (100, 100), radius = (200 - 20) / 2 = 90.
      // Point at (100 + 90, 100) = (190, 100) is on 0 radians -> should hit index 0.
      final hit0 = RingMath.hitTestSegment(
        localPosition: const Offset(190, 100),
        size: size,
        strokeWidth: strokeWidth,
        arcs: arcs,
      );
      expect(hit0, 0);

      // Point at center (100, 100) should return null (inside inner hole)
      final hitCenter = RingMath.hitTestSegment(
        localPosition: const Offset(100, 100),
        size: size,
        strokeWidth: strokeWidth,
        arcs: arcs,
      );
      expect(hitCenter, isNull);
    });

    test('hitTestNestedRing detects concentric bands', () {
      const size = Size(200, 200);
      const strokeWidth = 20.0;
      const ringSpacing = 4.0;
      // Max outer radius = (200 - 20) / 2 = 90.
      // Ring 0 radius = 90. Tap at (100 + 90, 100) = (190, 100)
      final hit0 = RingMath.hitTestNestedRing(
        localPosition: const Offset(190, 100),
        size: size,
        ringCount: 3,
        strokeWidth: strokeWidth,
        ringSpacing: ringSpacing,
      );
      expect(hit0, 0);

      // Ring 1 radius = 90 - (20 + 4) = 66. Tap at (100 + 66, 100) = (166, 100)
      final hit1 = RingMath.hitTestNestedRing(
        localPosition: const Offset(166, 100),
        size: size,
        ringCount: 3,
        strokeWidth: strokeWidth,
        ringSpacing: ringSpacing,
      );
      expect(hit1, 1);
    });
  });
}
