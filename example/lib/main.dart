import 'package:flutter/material.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

void main() {
  runApp(const SegmentedRingDemoApp());
}

class SegmentedRingDemoApp extends StatelessWidget {
  const SegmentedRingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Segmented Ring Painter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Concentric Rings Data
  double _moveVal = 520;
  double _exerciseVal = 38;
  double _standVal = 10;
  String? _selectedRingLabel;

  // Segmented Ring Data
  double _carbs = 180;
  double _protein = 140;
  double _fat = 65;
  double _gapAngle = 6.0;
  final RingCapStyle _capStyle = RingCapStyle.round;
  String? _selectedSegmentLabel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Segmented Ring Painter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Activity Rings'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Segmented Breakdown'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityRingsTab(),
          _buildSegmentedTab(),
        ],
      ),
    );
  }

  Widget _buildActivityRingsTab() {
    final rings = [
      NestedRing(
        value: _moveVal,
        maxValue: 500,
        color: const Color(0xFFFA114F),
        label: 'Move',
      ),
      NestedRing(
        value: _exerciseVal,
        maxValue: 30,
        color: const Color(0xFFAAF724),
        label: 'Exercise',
      ),
      NestedRing(
        value: _standVal,
        maxValue: 12,
        color: const Color(0xFF00F5D4),
        label: 'Stand',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: NestedActivityRings(
                    rings: rings,
                    style: const NestedRingsStyle(
                      strokeWidth: 22.0,
                      ringSpacing: 5.0,
                      enableOverachievementShadow: true,
                    ),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Color(0xFFFA114F), size: 32),
                        const SizedBox(height: 4),
                        Text(
                          _selectedRingLabel ?? 'Daily Goals',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${((_moveVal / 500) * 100).toInt()}% Move',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    onRingTap: (index, ring) {
                      setState(() {
                        _selectedRingLabel =
                            '${ring.label}: ${ring.value.toInt()}/${ring.maxValue.toInt()}';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedRingLabel ?? 'Tap any ring to inspect metrics',
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Move: ${_moveVal.toInt()} / 500 kcal',
            value: _moveVal,
            min: 0,
            max: 800,
            color: const Color(0xFFFA114F),
            onChanged: (v) => setState(() => _moveVal = v),
          ),
          _buildSlider(
            label: 'Exercise: ${_exerciseVal.toInt()} / 30 mins',
            value: _exerciseVal,
            min: 0,
            max: 60,
            color: const Color(0xFFAAF724),
            onChanged: (v) => setState(() => _exerciseVal = v),
          ),
          _buildSlider(
            label: 'Stand: ${_standVal.toInt()} / 12 hrs',
            value: _standVal,
            min: 0,
            max: 16,
            color: const Color(0xFF00F5D4),
            onChanged: (v) => setState(() => _standVal = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab() {
    final double totalCalories = (_carbs * 4) + (_protein * 4) + (_fat * 9);

    final segments = [
      RingSegment(
        value: _carbs * 4,
        color: const Color(0xFF38BDF8),
        label: 'Carbs',
        shadowColor: const Color(0xFF38BDF8),
        shadowBlur: 6,
      ),
      RingSegment(
        value: _protein * 4,
        color: const Color(0xFF34D399),
        label: 'Protein',
        shadowColor: const Color(0xFF34D399),
        shadowBlur: 6,
      ),
      RingSegment(
        value: _fat * 9,
        color: const Color(0xFFFBBF24),
        label: 'Fats',
        shadowColor: const Color(0xFFFBBF24),
        shadowBlur: 6,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: SegmentedRingChart(
                    segments: segments,
                    style: SegmentedRingStyle(
                      strokeWidth: 24.0,
                      gapAngle: _gapAngle,
                      capStyle: _capStyle,
                      trackColor: const Color(0xFF334155),
                    ),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${totalCalories.toInt()}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Total kcal',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        if (_selectedSegmentLabel != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedSegmentLabel!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    onSegmentTap: (index, seg) {
                      setState(() {
                        final pct = (seg.value / totalCalories * 100).toInt();
                        _selectedSegmentLabel =
                            '${seg.label}: ${seg.value.toInt()} kcal ($pct%)';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedSegmentLabel ??
                      'Tap any segment to view macro share',
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label:
                'Carbohydrates: ${_carbs.toInt()}g (${(_carbs * 4).toInt()} kcal)',
            value: _carbs,
            min: 50,
            max: 350,
            color: const Color(0xFF38BDF8),
            onChanged: (v) => setState(() => _carbs = v),
          ),
          _buildSlider(
            label:
                'Protein: ${_protein.toInt()}g (${(_protein * 4).toInt()} kcal)',
            value: _protein,
            min: 40,
            max: 250,
            color: const Color(0xFF34D399),
            onChanged: (v) => setState(() => _protein = v),
          ),
          _buildSlider(
            label: 'Fats: ${_fat.toInt()}g (${(_fat * 9).toInt()} kcal)',
            value: _fat,
            min: 20,
            max: 120,
            color: const Color(0xFFFBBF24),
            onChanged: (v) => setState(() => _fat = v),
          ),
          _buildSlider(
            label: 'Gap Angle: ${_gapAngle.toStringAsFixed(1)}°',
            value: _gapAngle,
            min: 0,
            max: 20,
            color: Colors.grey,
            onChanged: (v) => setState(() => _gapAngle = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: color,
            inactiveColor: const Color(0xFF334155),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
