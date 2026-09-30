import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_segment.dart';

/// Pre-calculated geometrical arc information for rendering and hit-testing.
class ComputedArc {
  /// The original index of the segment in the input list.
  final int index;

  /// Starting angle of the arc in radians.
  final double startAngle;

  /// Sweep angle of the arc in radians.
  final double sweepAngle;

  /// Associated data segment.
  final RingSegment segment;

  /// Creates a [ComputedArc].
  const ComputedArc({
    required this.index,
    required this.startAngle,
    required this.sweepAngle,
    required this.segment,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComputedArc &&
        other.index == index &&
        (other.startAngle - startAngle).abs() < 1e-6 &&
        (other.sweepAngle - sweepAngle).abs() < 1e-6 &&
        other.segment == segment;
  }

  @override
  int get hashCode => Object.hash(index, startAngle, sweepAngle, segment);
}

/// Mathematical helpers for ring geometry, angles, and hit-testing.
class RingMath {
  /// Converts degrees to radians.
  static double degreesToRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Converts radians to degrees.
  static double radiansToDegrees(double radians) => radians * (180.0 / math.pi);

  /// Normalizes an angle in radians to the range `[0, 2 * pi)`.
  static double normalizeRadians(double radians) {
    const double twoPi = 2 * math.pi;
    double result = radians % twoPi;
    if (result < 0) {
      result += twoPi;
    }
    return result;
  }

  /// Calculates the layout arcs for a list of [RingSegment]s.
  static List<ComputedArc> calculateSegmentArcs({
    required List<RingSegment> segments,
    required double startAngleRad,
    required double gapAngleRad,
    required double animationProgress,
    SegmentedRingMode mode = SegmentedRingMode.proportional,
    double? totalValue,
  }) {
    if (segments.isEmpty || animationProgress <= 0.0) {
      return const [];
    }

    final double clampedProgress = animationProgress.clamp(0.0, 1.0);
    final int count = segments.length;

    // Compute sum of values
    double sumValues = 0.0;
    for (final seg in segments) {
      sumValues += seg.value;
    }

    if (sumValues <= 0.0 && totalValue == null) {
      return const [];
    }

    final double effectiveTotal = (mode == SegmentedRingMode.absolute &&
            totalValue != null &&
            totalValue > 0)
        ? totalValue
        : (sumValues > 0 ? sumValues : 1.0);

    const double twoPi = 2 * math.pi;

    // Total gap angle across all segments
    final double totalGapRad = count > 1 ? (count * gapAngleRad) : 0.0;
    final double usableSweepRad = math.max(0.0, twoPi - totalGapRad);

    final List<ComputedArc> arcs = [];
    double currentStartRad = startAngleRad;

    for (int i = 0; i < count; i++) {
      final seg = segments[i];
      final double fraction = (seg.value / effectiveTotal).clamp(0.0, 1.0);
      final double targetSweepRad =
          (usableSweepRad * fraction) * clampedProgress;

      if (targetSweepRad > 0) {
        arcs.add(ComputedArc(
          index: i,
          startAngle: currentStartRad,
          sweepAngle: targetSweepRad,
          segment: seg,
        ));
      }

      // Advance start angle for next segment (including its proportional sweep + gap)
      final double fullSegmentSweep = (usableSweepRad * fraction);
      currentStartRad += fullSegmentSweep + (count > 1 ? gapAngleRad : 0.0);
    }

    return arcs;
  }

  /// Hit-tests a local tap position against a single segmented ring.
  /// Returns the index of the tapped segment, or null if outside.
  static int? hitTestSegment({
    required Offset localPosition,
    required Size size,
    required double strokeWidth,
    required List<ComputedArc> arcs,
  }) {
    if (arcs.isEmpty) return null;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    if (radius <= 0) return null;

    final double dx = localPosition.dx - center.dx;
    final double dy = localPosition.dy - center.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);

    // Check if distance is within the ring stroke boundary (with a slight 2px padding for touch ease)
    final double innerRadius = radius - (strokeWidth / 2) - 2.0;
    final double outerRadius = radius + (strokeWidth / 2) + 2.0;

    if (distance < innerRadius || distance > outerRadius) {
      return null;
    }

    // Compute angle from center
    final double tapAngle = math.atan2(dy, dx);
    final double normalizedTap = normalizeRadians(tapAngle);

    for (final arc in arcs) {
      final double arcStart = normalizeRadians(arc.startAngle);
      final double arcSweep = arc.sweepAngle;

      if (isAngleInsideArc(normalizedTap, arcStart, arcSweep)) {
        return arc.index;
      }
    }

    return null;
  }

  /// Determines if [targetAngle] in `[0, 2*pi)` lies within the arc starting at [startAngle] with [sweepAngle].
  static bool isAngleInsideArc(
      double targetAngle, double startAngle, double sweepAngle) {
    if (sweepAngle >= 2 * math.pi) return true;

    final double normalizedStart = normalizeRadians(startAngle);
    final double normalizedEnd = normalizeRadians(startAngle + sweepAngle);

    if (normalizedStart <= normalizedEnd) {
      return targetAngle >= normalizedStart && targetAngle <= normalizedEnd;
    } else {
      // Arc crosses 0 rad / 360 deg boundary
      return targetAngle >= normalizedStart || targetAngle <= normalizedEnd;
    }
  }

  /// Hit-tests a local tap position against nested concentric rings.
  /// Returns the index of the tapped ring (0 = outermost), or null if outside.
  static int? hitTestNestedRing({
    required Offset localPosition,
    required Size size,
    required int ringCount,
    required double strokeWidth,
    required double ringSpacing,
  }) {
    if (ringCount <= 0) return null;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxOuterRadius =
        (math.min(size.width, size.height) - strokeWidth) / 2;

    final double dx = localPosition.dx - center.dx;
    final double dy = localPosition.dy - center.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);

    for (int i = 0; i < ringCount; i++) {
      final double ringRadius =
          maxOuterRadius - i * (strokeWidth + ringSpacing);
      if (ringRadius <= 0) break;

      final double inner = ringRadius - (strokeWidth / 2) - 2.0;
      final double outer = ringRadius + (strokeWidth / 2) + 2.0;

      if (distance >= inner && distance <= outer) {
        return i;
      }
    }

    return null;
  }
}

/// Helper to create angular gradient shaders for ring arcs.
class RingGradientHelper {
  /// Builds a sweep gradient centered on the circle.
  static SweepGradient sweep({
    required List<Color> colors,
    List<double>? stops,
    double startAngle = 0.0,
    double endAngle = 6.283185307179586,
  }) {
    return SweepGradient(
      colors: colors,
      stops: stops,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }
}
