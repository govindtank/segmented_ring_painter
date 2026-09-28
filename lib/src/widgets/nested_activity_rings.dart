import 'package:flutter/material.dart';
import '../models/nested_ring.dart';
import '../models/ring_style.dart';
import '../painters/nested_ring_painter.dart';
import '../utils/ring_math.dart';

/// An interactive concentric activity rings widget (Apple Fitness / Aura ring style) for Flutter.
class NestedActivityRings extends StatefulWidget {
  /// The list of concentric rings ordered from outermost to innermost.
  final List<NestedRing> rings;

  /// Visual styling configuration.
  final NestedRingsStyle style;

  /// Optional widget displayed in the center of the innermost ring.
  final Widget? center;

  /// Animation duration for entrance and value updates.
  final Duration animationDuration;

  /// Curve used for the animation.
  final Curve animationCurve;

  /// Callback fired when a ring is tapped.
  final void Function(int index, NestedRing ring)? onRingTap;

  /// Optional fixed width. If null, expands to fill parent.
  final double? width;

  /// Optional fixed height. If null, expands to fill parent.
  final double? height;

  /// Creates a [NestedActivityRings].
  const NestedActivityRings({
    super.key,
    required this.rings,
    this.style = const NestedRingsStyle(),
    this.center,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeOutCubic,
    this.onRingTap,
    this.width,
    this.height,
  });

  @override
  State<NestedActivityRings> createState() => _NestedActivityRingsState();
}

class _NestedActivityRingsState extends State<NestedActivityRings>
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
  void didUpdateWidget(NestedActivityRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (!_areRingsIdentical(oldWidget.rings, widget.rings)) {
      _controller.forward(from: 0.0);
    }
  }

  bool _areRingsIdentical(List<NestedRing> a, List<NestedRing> b) {
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

  void _handleTap(TapUpDetails details, Size size) {
    final int? tappedIndex = RingMath.hitTestNestedRing(
      localPosition: details.localPosition,
      size: size,
      ringCount: widget.rings.length,
      strokeWidth: widget.style.strokeWidth,
      ringSpacing: widget.style.ringSpacing,
    );

    setState(() {
      _selectedIndex = tappedIndex;
    });

    if (tappedIndex != null &&
        widget.onRingTap != null &&
        tappedIndex < widget.rings.length) {
      widget.onRingTap!(tappedIndex, widget.rings[tappedIndex]);
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
            final NestedRingPainter painter = NestedRingPainter(
              rings: widget.rings,
              style: widget.style,
              animationProgress: _animation.value,
              selectedIndex: _selectedIndex,
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleTap(details, size),
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
