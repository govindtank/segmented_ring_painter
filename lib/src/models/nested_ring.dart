import 'package:flutter/material.dart';

/// Represents a single concentric ring in a [NestedActivityRings] chart (Apple Fitness style).
class NestedRing {
  /// The current completed value for this ring.
  final double value;

  /// The target or maximum goal value for this ring. Must be positive.
  final double maxValue;

  /// The primary fill color of the ring.
  final Color color;

  /// Optional gradient fill for this ring.
  final Gradient? gradient;

  /// Optional background track color. If null, a dimmed version of [color] is used.
  final Color? trackColor;

  /// Optional label for this ring (e.g. 'Move', 'Exercise', 'Stand').
  final String? label;

  /// Optional custom payload attached to this ring.
  final dynamic data;

  /// Optional custom stroke width override for this specific ring.
  final double? strokeWidth;

  /// Creates a [NestedRing].
  const NestedRing({
    required this.value,
    required this.maxValue,
    required this.color,
    this.gradient,
    this.trackColor,
    this.label,
    this.data,
    this.strokeWidth,
  })  : assert(value >= 0, 'Ring value must be non-negative'),
        assert(maxValue > 0, 'Ring maxValue must be strictly positive');

  /// Returns the normalized progress ratio (e.g. 0.75 for 75%, 1.25 for 125%).
  double get progress => maxValue > 0 ? (value / maxValue) : 0.0;

  /// Returns true if the goal has been achieved or exceeded (progress >= 1.0).
  bool get isCompleted => progress >= 1.0;

  /// Creates a copy of this [NestedRing] with updated fields.
  NestedRing copyWith({
    double? value,
    double? maxValue,
    Color? color,
    Gradient? gradient,
    Color? trackColor,
    String? label,
    dynamic data,
    double? strokeWidth,
  }) {
    return NestedRing(
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      trackColor: trackColor ?? this.trackColor,
      label: label ?? this.label,
      data: data ?? this.data,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NestedRing &&
        other.value == value &&
        other.maxValue == maxValue &&
        other.color == color &&
        other.gradient == gradient &&
        other.trackColor == trackColor &&
        other.label == label &&
        other.data == data &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode => Object.hash(
        value,
        maxValue,
        color,
        gradient,
        trackColor,
        label,
        data,
        strokeWidth,
      );

  @override
  String toString() =>
      'NestedRing(label: $label, value: $value/$maxValue, progress: ${(progress * 100).toStringAsFixed(1)}%)';
}
