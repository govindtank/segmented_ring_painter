import 'package:flutter_test/flutter_test.dart';
import 'package:segmented_ring_painter_example/main.dart';

void main() {
  testWidgets('Example app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SegmentedRingDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Segmented Ring Painter'), findsOneWidget);
    expect(find.text('Activity Rings'), findsOneWidget);
    expect(find.text('Segmented Breakdown'), findsOneWidget);
  });
}
