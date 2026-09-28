import 'package:flutter/material.dart';
import '../models/ring_segment.dart';
import '../models/ring_style.dart';
import '../painters/segmented_ring_painter.dart';
import '../utils/ring_math.dart';

/// An interactive, high-performance segmented circular ring chart widget for Flutter.
class SegmentedRingChart extends StatefulWidget {
  /// The list of data segments to display.
  final List<RingSegment> segments;

  /// Visual styling configuration.
  final SegmentedRingStyle style;

  /// Segmentation calculation mode (proportional or absolute).
  final SegmentedRingMode mode;

  /// Optional total value for absolute mode.
  final double? totalValue;

  /// Optional widget displayed in the center of the ring (e.g. score, icon, label).
  final Widget? center;

  /// Animation duration for entrance and value updates.
  final Duration animationDuration;

  /// Curve used for the animation.
  final Curve animationCurve;

  /// Callback fired when a segment is tapped.
  final void Function(int index, RingSegment segment)? onSegmentTap;

  /// Optional fixed width. If null, expands to fill parent.
  final double? width;

  /// Optional fixed height. If null, expands to fill parent.
  final double? height;

  /// Creates a [SegmentedRingChart].
  const SegmentedRingChart({
    super.key,
    required this.segments,
    this.style = const SegmentedRingStyle(),
    this.mode = SegmentedRingMode.proportional,
    this.totalValue,
    this.center,
    this.animationDuration = const Duration(milliseconds: 900),
    this.animationCurve = Curves.easeOutCubic,
    this.onSegmentTap,
    this.width,
    this.height,
  });

  @override
  State<SegmentedRingChart> createState() => _SegmentedRingChartState();
}

class _SegmentedRingChartState extends State<SegmentedRingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SegmentedRingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (!_areSegmentsIdentical(oldWidget.segments, widget.segments)) {
      _controller.forward(from: 0.0);
    }
  }

  bool _areSegmentsIdentical(List<RingSegment> a, List<RingSegment> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details, Size size, List<ComputedArc> arcs) {
    final int? tappedIndex = RingMath.hitTestSegment(
      localPosition: details.localPosition,
      size: size,
      strokeWidth: widget.style.strokeWidth,
      arcs: arcs,
    );

    setState(() {
      _selectedIndex = tappedIndex;
    });

    if (tappedIndex != null &&
        widget.onSegmentTap != null &&
        tappedIndex < widget.segments.length) {
      widget.onSegmentTap!(tappedIndex, widget.segments[tappedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget chart = LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveWidth = widget.width ?? constraints.maxWidth;
        final double effectiveHeight = widget.height ?? constraints.maxHeight;
        final Size size = Size(effectiveWidth, effectiveHeight);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final SegmentedRingPainter painter = SegmentedRingPainter(
              segments: widget.segments,
              style: widget.style,
              animationProgress: _animation.value,
              mode: widget.mode,
              totalValue: widget.totalValue,
              selectedIndex: _selectedIndex,
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) =>
                  _handleTap(details, size, painter.computedArcs),
              child: CustomPaint(
                size: size,
                painter: painter,
                child:
                    widget.center != null ? Center(child: widget.center) : null,
              ),
            );
          },
        );
      },
    );

    if (widget.width != null || widget.height != null) {
      chart = SizedBox(
        width: widget.width,
        height: widget.height,
        child: chart,
      );
    } else {
      chart = AspectRatio(
        aspectRatio: 1.0,
        child: chart,
      );
    }

    return chart;
  }
}
