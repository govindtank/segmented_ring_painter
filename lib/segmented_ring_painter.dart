/// Production-ready segmented circular progress and concentric activity ring library for Flutter.
///
/// Provides GPU-accelerated [CustomPainter] and interactive widgets for segmented progress rings,
/// Apple Fitness-style concentric activity rings, gradient arcs, gap trigonometry, and tap hit-testing.
///
/// Implementation by Govind Tank.
library segmented_ring_painter;

export 'src/models/ring_segment.dart';
export 'src/models/nested_ring.dart';
export 'src/models/ring_style.dart';
export 'src/utils/ring_math.dart';
export 'src/painters/segmented_ring_painter.dart';
export 'src/painters/nested_ring_painter.dart';
export 'src/widgets/segmented_ring_chart.dart';
export 'src/widgets/nested_activity_rings.dart';
