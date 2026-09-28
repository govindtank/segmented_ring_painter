import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/nested_ring.dart';
import '../models/ring_segment.dart';
import '../models/ring_style.dart';
import '../utils/ring_math.dart';

/// High-performance [CustomPainter] that renders multi-metric concentric activity rings (Apple Fitness style).
class NestedRingPainter extends CustomPainter {
  /// The list of concentric rings ordered from outermost (index 0) to innermost.
  final List<NestedRing> rings;

  /// Visual styling configuration.
  final NestedRingsStyle style;

  /// Animation progress multiplier in `[0.0, 1.0]`.
  final double animationProgress;

  /// Optional index of selected ring for interactive highlighting.
  final int? selectedIndex;

  /// Creates a [NestedRingPainter].
  const NestedRingPainter({
    required this.rings,
    this.style = const NestedRingsStyle(),
    this.animationProgress = 1.0,
    this.selectedIndex,
  });

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
    if (size.width <= 0 || size.height <= 0 || rings.isEmpty) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxStrokeWidth = style.strokeWidth;
    final double maxOuterRadius =
        (math.min(size.width, size.height) - maxStrokeWidth) / 2;

    if (maxOuterRadius <= 0) return;

    final StrokeCap cap = _mapCapStyle(style.capStyle);
    final double startAngleRad = RingMath.degreesToRadians(style.startAngle);
    const double twoPi = 2 * math.pi;

    for (int i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final double strokeW = ring.strokeWidth ?? style.strokeWidth;
      final double ringRadius =
          maxOuterRadius - i * (style.strokeWidth + style.ringSpacing);

      if (ringRadius <= 0) break;

      final Rect rect = Rect.fromCircle(center: center, radius: ringRadius);
      final bool isSelected = selectedIndex == i;
      final double currentStrokeW = isSelected ? strokeW + 4.0 : strokeW;

      // 1. Draw Background Track
      final Paint trackPaint = Paint()
        ..color = ring.trackColor ??
            ring.color.withValues(alpha: style.defaultTrackOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentStrokeW
        ..isAntiAlias = true;

      canvas.drawCircle(center, ringRadius, trackPaint);

      // 2. Compute Animated Progress Sweep Angle
      final double ringProgress = (ring.progress * animationProgress)
          .clamp(0.0, 5.0); // Allow up to 500% overachievement
      if (ringProgress <= 0) continue;

      final double totalSweepRad = ringProgress * twoPi;

      final Paint ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = cap
        ..strokeWidth = currentStrokeW
        ..isAntiAlias = true;

      if (ring.gradient != null) {
        ringPaint.shader = ring.gradient!.createShader(rect);
      } else {
        ringPaint.color = ring.color;
      }

      if (totalSweepRad <= twoPi) {
        // Standard single lap
        canvas.drawArc(rect, startAngleRad, totalSweepRad, false, ringPaint);
      } else {
        // Overachievement (> 100%): draw base circle first
        canvas.drawArc(rect, startAngleRad, twoPi, false, ringPaint);

        // Draw overlapping excess arc
        final double excessSweep = totalSweepRad - twoPi;

        // Render end cap shadow under the start overlap for 3D depth
        if (style.enableOverachievementShadow &&
            style.capStyle == RingCapStyle.round) {
          final Offset startPoint = Offset(
            center.dx + ringRadius * math.cos(startAngleRad),
            center.dy + ringRadius * math.sin(startAngleRad),
          );

          final Paint shadowPaint = Paint()
            ..color = style.overachievementShadowColor
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentStrokeW / 3)
            ..isAntiAlias = true;

          canvas.drawCircle(startPoint, currentStrokeW / 2 + 1.0, shadowPaint);
        }

        canvas.drawArc(rect, startAngleRad, excessSweep, false, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(NestedRingPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.style != style ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.rings.length != rings.length ||
        !_areRingsEqual(oldDelegate.rings, rings);
  }

  bool _areRingsEqual(List<NestedRing> a, List<NestedRing> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
