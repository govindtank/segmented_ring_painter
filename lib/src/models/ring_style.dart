import 'package:flutter/material.dart';
import 'ring_segment.dart';

/// Configuration styling for [SegmentedRingChart].
class SegmentedRingStyle {
  /// Thickness of the ring stroke in logical pixels.
  final double strokeWidth;

  /// Angular gap in degrees between adjacent segments.
  final double gapAngle;

  /// Cap style for segment ends (round, butt, square).
  final RingCapStyle capStyle;

  /// Whether to render a continuous background track behind the segments.
  final bool showTrack;

  /// Background track color.
  final Color trackColor;

  /// Optional custom stroke width for the background track.
  final double? trackStrokeWidth;

  /// Starting angle in degrees (e.g. -90.0 starts at 12 o'clock / top center).
  final double startAngle;

  /// Optional glow or shadow effect around the entire ring.
  final Color? glowColor;

  /// Blur radius for the ring glow effect.
  final double glowBlur;

  /// Creates a [SegmentedRingStyle].
  const SegmentedRingStyle({
    this.strokeWidth = 20.0,
    this.gapAngle = 4.0,
    this.capStyle = RingCapStyle.round,
    this.showTrack = true,
    this.trackColor = const Color(0x1FFFFFFF),
    this.trackStrokeWidth,
    this.startAngle = -90.0,
    this.glowColor,
    this.glowBlur = 8.0,
  })  : assert(strokeWidth > 0, 'strokeWidth must be positive'),
        assert(gapAngle >= 0 && gapAngle < 360, 'gapAngle must be in [0, 360)');

  /// Creates a copy of this style with updated fields.
  SegmentedRingStyle copyWith({
    double? strokeWidth,
    double? gapAngle,
    RingCapStyle? capStyle,
    bool? showTrack,
    Color? trackColor,
    double? trackStrokeWidth,
    double? startAngle,
    Color? glowColor,
    double? glowBlur,
  }) {
    return SegmentedRingStyle(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      gapAngle: gapAngle ?? this.gapAngle,
      capStyle: capStyle ?? this.capStyle,
      showTrack: showTrack ?? this.showTrack,
      trackColor: trackColor ?? this.trackColor,
      trackStrokeWidth: trackStrokeWidth ?? this.trackStrokeWidth,
      startAngle: startAngle ?? this.startAngle,
      glowColor: glowColor ?? this.glowColor,
      glowBlur: glowBlur ?? this.glowBlur,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SegmentedRingStyle &&
        other.strokeWidth == strokeWidth &&
        other.gapAngle == gapAngle &&
        other.capStyle == capStyle &&
        other.showTrack == showTrack &&
        other.trackColor == trackColor &&
        other.trackStrokeWidth == trackStrokeWidth &&
        other.startAngle == startAngle &&
        other.glowColor == glowColor &&
        other.glowBlur == glowBlur;
  }

  @override
  int get hashCode => Object.hash(
        strokeWidth,
        gapAngle,
        capStyle,
        showTrack,
        trackColor,
        trackStrokeWidth,
        startAngle,
        glowColor,
        glowBlur,
      );
}

/// Configuration styling for [NestedActivityRings].
class NestedRingsStyle {
  /// Thickness of each concentric ring stroke in logical pixels.
  final double strokeWidth;

  /// Spacing gap between adjacent concentric rings.
  final double ringSpacing;

  /// Cap style for ring ends.
  final RingCapStyle capStyle;

  /// Starting angle in degrees (default: -90.0 for 12 o'clock).
  final double startAngle;

  /// Opacity multiplier for background tracks when ring has no explicit `trackColor`.
  final double defaultTrackOpacity;

  /// Whether to render overlapping end-cap drop shadows when a ring exceeds 100% progress.
  final bool enableOverachievementShadow;

  /// Color of the overachievement end-cap shadow.
  final Color overachievementShadowColor;

  /// Creates a [NestedRingsStyle].
  const NestedRingsStyle({
    this.strokeWidth = 24.0,
    this.ringSpacing = 4.0,
    this.capStyle = RingCapStyle.round,
    this.startAngle = -90.0,
    this.defaultTrackOpacity = 0.2,
    this.enableOverachievementShadow = true,
    this.overachievementShadowColor = const Color(0x99000000),
  })  : assert(strokeWidth > 0, 'strokeWidth must be positive'),
        assert(ringSpacing >= 0, 'ringSpacing must be non-negative');

  /// Creates a copy of this style with updated fields.
  NestedRingsStyle copyWith({
    double? strokeWidth,
    double? ringSpacing,
    RingCapStyle? capStyle,
    double? startAngle,
    double? defaultTrackOpacity,
    bool? enableOverachievementShadow,
    Color? overachievementShadowColor,
  }) {
    return NestedRingsStyle(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      ringSpacing: ringSpacing ?? this.ringSpacing,
      capStyle: capStyle ?? this.capStyle,
      startAngle: startAngle ?? this.startAngle,
      defaultTrackOpacity: defaultTrackOpacity ?? this.defaultTrackOpacity,
      enableOverachievementShadow:
          enableOverachievementShadow ?? this.enableOverachievementShadow,
      overachievementShadowColor:
          overachievementShadowColor ?? this.overachievementShadowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NestedRingsStyle &&
        other.strokeWidth == strokeWidth &&
        other.ringSpacing == ringSpacing &&
        other.capStyle == capStyle &&
        other.startAngle == startAngle &&
        other.defaultTrackOpacity == defaultTrackOpacity &&
        other.enableOverachievementShadow == enableOverachievementShadow &&
        other.overachievementShadowColor == overachievementShadowColor;
  }

  @override
  int get hashCode => Object.hash(
        strokeWidth,
        ringSpacing,
        capStyle,
        startAngle,
        defaultTrackOpacity,
        enableOverachievementShadow,
        overachievementShadowColor,
      );
}
