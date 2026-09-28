import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_segment.dart';
import '../models/ring_style.dart';
import '../utils/ring_math.dart';

/// High-performance [CustomPainter] that renders a segmented circular ring.
class SegmentedRingPainter extends CustomPainter {
  /// The list of data segments to draw.
  final List<RingSegment> segments;

  /// Visual styling configuration.
  final SegmentedRingStyle style;

  /// Animation progress multiplier in `[0.0, 1.0]`.
  final double animationProgress;

  /// Segmentation calculation mode.
  final SegmentedRingMode mode;

  /// Optional total value for absolute mode.
  final double? totalValue;

  /// Optional index of currently selected/hovered segment for highlighting.
  final int? selectedIndex;

  /// Pre-computed arc data exposed for hit-testing and testing.
  final List<ComputedArc> computedArcs;

  /// Creates a [SegmentedRingPainter].
  SegmentedRingPainter({
    required this.segments,
    this.style = const SegmentedRingStyle(),
    this.animationProgress = 1.0,
    this.mode = SegmentedRingMode.proportional,
    this.totalValue,
    this.selectedIndex,
  }) : computedArcs = RingMath.calculateSegmentArcs(
          segments: segments,
          startAngleRad: RingMath.degreesToRadians(style.startAngle),
          gapAngleRad: RingMath.degreesToRadians(style.gapAngle),
          animationProgress: animationProgress,
          mode: mode,
          totalValue: totalValue,
        );

  StrokeCap _mapCapStyle(RingCapStyle capStyle) {
    switch (capStyle) {
      case RingCapStyle.round:
        return StrokeCap.round;
      case RingCapStyle.butt:
        return StrokeCap.butt;
      case RingCapStyle.square:
        return StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        (math.min(size.width, size.height) - style.strokeWidth) / 2;

    if (radius <= 0) return;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final StrokeCap cap = _mapCapStyle(style.capStyle);

    // 1. Draw Background Track
    if (style.showTrack) {
      final Paint trackPaint = Paint()
        ..color = style.trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.trackStrokeWidth ?? style.strokeWidth
        ..isAntiAlias = true;

      if (style.gapAngle == 0.0 || segments.length <= 1) {
        // Continuous circular track
        canvas.drawCircle(center, radius, trackPaint);
      } else {
        // Segmented track with gaps
        trackPaint.strokeCap = cap;
        final double startRad = RingMath.degreesToRadians(style.startAngle);
        final double gapRad = RingMath.degreesToRadians(style.gapAngle);
        final double fullSweep =
            (2 * math.pi - (segments.length * gapRad)) / segments.length;

        double currentStart = startRad;
        for (int i = 0; i < segments.length; i++) {
          canvas.drawArc(rect, currentStart, fullSweep, false, trackPaint);
          currentStart += fullSweep + gapRad;
        }
      }
    }

    // 2. Draw Outer Glow (if specified)
    if (style.glowColor != null && style.glowBlur > 0) {
      final Paint glowPaint = Paint()
        ..color = style.glowColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, style.glowBlur)
        ..isAntiAlias = true;

      for (final arc in computedArcs) {
        canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, glowPaint);
      }
    }

    // 3. Draw Active Data Segments
    for (final arc in computedArcs) {
      final bool isSelected = selectedIndex == arc.index;
      final double strokeW =
          isSelected ? style.strokeWidth + 4.0 : style.strokeWidth;

      // Segment Shadow pass
      if (arc.segment.shadowColor != null &&
          (arc.segment.shadowBlur ?? 0) > 0) {
        final Paint shadowPaint = Paint()
          ..color = arc.segment.shadowColor!
          ..style = PaintingStyle.stroke
          ..strokeCap = cap
          ..strokeWidth = strokeW
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, arc.segment.shadowBlur!)
          ..isAntiAlias = true;

        canvas.drawArc(
            rect, arc.startAngle, arc.sweepAngle, false, shadowPaint);
      }

      // Main Segment Stroke
      final Paint segmentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = cap
        ..strokeWidth = strokeW
        ..isAntiAlias = true;

      if (arc.segment.gradient != null) {
        segmentPaint.shader = arc.segment.gradient!.createShader(rect);
      } else {
        segmentPaint.color = arc.segment.color;
      }

      canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, segmentPaint);
    }
  }

  @override
  bool shouldRepaint(SegmentedRingPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.style != style ||
        oldDelegate.mode != mode ||
        oldDelegate.totalValue != totalValue ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segments.length != segments.length ||
        !_areSegmentsEqual(oldDelegate.segments, segments);
  }

  bool _areSegmentsEqual(List<RingSegment> a, List<RingSegment> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
