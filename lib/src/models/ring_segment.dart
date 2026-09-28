import 'package:flutter/material.dart';

/// Defines how the ends of arc segments are capped.
enum RingCapStyle {
  /// Rounded circular end caps.
  round,

  /// Flat end caps flush with the end of the arc.
  butt,

  /// Square end caps extending beyond the arc by half the stroke width.
  square,
}

/// Defines the computation mode for segment proportions.
enum SegmentedRingMode {
  /// Segments are proportioned relative to the sum of all segment values (100% total).
  proportional,

  /// Segments are proportioned against an explicit [totalValue].
  absolute,

  /// Ring is divided into equal discrete tick marks up to total capacity.
  stepped,
}

/// Represents a single data segment within a [SegmentedRingChart].
class RingSegment {
  /// The numeric value of this segment. Must be non-negative.
  final double value;

  /// The primary fill color of the segment.
  final Color color;

  /// Optional gradient fill for this segment. If provided, overrides [color].
  final Gradient? gradient;

  /// Optional human-readable label for this segment (e.g. 'Carbs', 'Budget').
  final String? label;

  /// Optional custom payload attached to this segment.
  final dynamic data;

  /// Optional outer glow or shadow color.
  final Color? shadowColor;

  /// Optional blur radius for the shadow.
  final double? shadowBlur;

  /// Creates a [RingSegment].
  const RingSegment({
    required this.value,
    required this.color,
    this.gradient,
    this.label,
    this.data,
    this.shadowColor,
    this.shadowBlur,
  }) : assert(value >= 0, 'Segment value must be non-negative');

  /// Creates a copy of this [RingSegment] with updated fields.
  RingSegment copyWith({
    double? value,
    Color? color,
    Gradient? gradient,
    String? label,
    dynamic data,
    Color? shadowColor,
    double? shadowBlur,
  }) {
    return RingSegment(
      value: value ?? this.value,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      label: label ?? this.label,
      data: data ?? this.data,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RingSegment &&
        other.value == value &&
        other.color == color &&
        other.gradient == gradient &&
        other.label == label &&
        other.data == data &&
        other.shadowColor == shadowColor &&
        other.shadowBlur == shadowBlur;
  }

  @override
  int get hashCode => Object.hash(
        value,
        color,
        gradient,
        label,
        data,
        shadowColor,
        shadowBlur,
      );

  @override
  String toString() =>
      'RingSegment(value: $value, color: $color, label: $label)';
}
