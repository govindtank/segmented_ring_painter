# segmented_ring_painter

[![Pub Version](https://img.shields.io/pub/v/segmented_ring_painter.svg?style=flat-square&color=blue)](https://pub.dev/packages/segmented_ring_painter)
[![Pub Points](https://img.shields.io/pub/points/segmented_ring_painter?style=flat-square&color=2E8B57&label=pub%20points)](https://pub.dev/packages/segmented_ring_painter/score)
[![Pub Likes](https://img.shields.io/pub/likes/segmented_ring_painter?style=flat-square)](https://pub.dev/packages/segmented_ring_painter)
[![CI](https://github.com/govindtank/segmented_ring_painter/actions/workflows/ci.yml/badge.svg)](https://github.com/govindtank/segmented_ring_painter/actions)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

A high-performance, GPU-accelerated Flutter package for rendering **segmented progress rings** and **Apple Fitness-style concentric activity rings** with gradient arcs, angular gaps, rounded caps, smooth physics animations, and tap hit-testing.

<p align="center">
  <img src="https://raw.githubusercontent.com/govindtank/segmented_ring_painter/main/screenshot.svg" width="750" alt="segmented_ring_painter demo"/>
</p>

---

## ✨ Features

- 🏃 **Concentric Activity Rings (`NestedActivityRings`)**: Apple Fitness-style nested rings with authentic overlap drop-shadows on overachievement (>100% goal).
- 🍰 **Proportional & Segmented Rings (`SegmentedRingChart`)**: Dynamic multi-segment progress circles with precise angular gap spacing (perfect for Macro/Nutrition breakdowns, Budget allocation, or Multi-phase workflows).
- 🎨 **Rich Styling**: Solid colors, sweep gradients, outer glow filters, and customizable end caps (`RingCapStyle.round`, `butt`, `square`).
- 👆 **Built-in Touch Hit-Testing**: Tap any individual segment or concentric ring to trigger tooltips, detail sheets, and selection states.
- ⚡ **Buttery Smooth**: Hardware-accelerated `CustomPainter` with strict `shouldRepaint` dirty checks to ensure steady 60/120 FPS.
- 🌐 **All 6 Platforms Supported**: 100% pure Dart & Flutter with zero native C/C++ dependencies. Works out-of-the-box on Android, iOS, Web, macOS, Windows, and Linux.

---

## 📦 Installation

Add `segmented_ring_painter` to your `pubspec.yaml`:

```yaml
dependencies:
  segmented_ring_painter: ^1.0.0
```

Or run:

```bash
flutter pub add segmented_ring_painter
```

---

## 🚀 Quick Start

### 1. Concentric Activity Rings (Apple Fitness Style)

```dart
import 'package:flutter/material.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

Widget buildActivityRings() {
  return NestedActivityRings(
    width: 220,
    height: 220,
    rings: [
      NestedRing(
        value: 520,
        maxValue: 500, // 104% -> Overachieved!
        color: const Color(0xFFFA114F),
        label: 'Move',
      ),
      NestedRing(
        value: 38,
        maxValue: 30,
        color: const Color(0xFFAAF724),
        label: 'Exercise',
      ),
      NestedRing(
        value: 9,
        maxValue: 12,
        color: const Color(0xFF00F5D4),
        label: 'Stand',
      ),
    ],
    style: const NestedRingsStyle(
      strokeWidth: 20.0,
      ringSpacing: 4.0,
      enableOverachievementShadow: true,
    ),
    center: const Icon(Icons.local_fire_department, color: Color(0xFFFA114F), size: 32),
    onRingTap: (index, ring) {
      print('Tapped ${ring.label}: ${ring.value}/${ring.maxValue}');
    },
  );
}
```

---

### 2. Segmented Proportional Ring (Nutrition / Budget)

```dart
import 'package:flutter/material.dart';
import 'package:segmented_ring_painter/segmented_ring_painter.dart';

Widget buildMacroBreakdown() {
  return SegmentedRingChart(
    width: 220,
    height: 220,
    segments: [
      RingSegment(
        value: 180 * 4, // Carbs kcal
        color: const Color(0xFF38BDF8),
        label: 'Carbs',
        shadowColor: const Color(0xFF38BDF8),
        shadowBlur: 6.0,
      ),
      RingSegment(
        value: 140 * 4, // Protein kcal
        color: const Color(0xFF34D399),
        label: 'Protein',
        shadowColor: const Color(0xFF34D399),
        shadowBlur: 6.0,
      ),
      RingSegment(
        value: 65 * 9, // Fat kcal
        color: const Color(0xFFFBBF24),
        label: 'Fats',
        shadowColor: const Color(0xFFFBBF24),
        shadowBlur: 6.0,
      ),
    ],
    style: const SegmentedRingStyle(
      strokeWidth: 22.0,
      gapAngle: 5.0, // 5° angular gap between segments
      capStyle: RingCapStyle.round,
    ),
    center: const Text(
      '1,865\nkcal',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
    onSegmentTap: (index, segment) {
      print('Selected segment: ${segment.label} (${segment.value} kcal)');
    },
  );
}
```

---

## 🛠️ API Reference

### `NestedActivityRings` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `rings` | `List<NestedRing>` | **Required** | Concentric ring configurations from outer to inner. |
| `style` | `NestedRingsStyle` | `NestedRingsStyle()` | Stroke thickness, spacing, shadows, and cap styling. |
| `center` | `Widget?` | `null` | Optional widget anchored at the center of the innermost ring. |
| `animationDuration` | `Duration` | `Duration(milliseconds: 1000)` | Duration for entrance & value change animations. |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Interpolation curve for smooth physics. |
| `onRingTap` | `Function(int, NestedRing)?` | `null` | Callback returning the tapped ring index and data. |

### `SegmentedRingChart` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `segments` | `List<RingSegment>` | **Required** | The data segments to partition across the ring. |
| `style` | `SegmentedRingStyle` | `SegmentedRingStyle()` | Stroke width, angular gap, background track, glow. |
| `mode` | `SegmentedRingMode` | `SegmentedRingMode.proportional` | `proportional` (auto-sums to 100%) or `absolute`. |
| `totalValue` | `double?` | `null` | Target total capacity for `SegmentedRingMode.absolute`. |
| `center` | `Widget?` | `null` | Optional center widget. |
| `onSegmentTap` | `Function(int, RingSegment)?` | `null` | Callback returning the tapped segment index and data. |

---

## 👨💻 Author & Maintainer

Developed and maintained by **Govind Tank**.

Contributions, bug reports, and feature suggestions are always welcome on [GitHub](https://github.com/govindtank/segmented_ring_painter)!

---

## 🌐 Ecosystem & Related Packages

Explore complementary production-grade libraries built for high-performance Flutter & Dart development:

| Package | Description | Version |
| :--- | :--- | :--- |
| **[`country_mobile_validator`](https://pub.dev/packages/country_mobile_validator)** | Zero-dependency per-country mobile validation (249 ISO regions). | `^0.2.0` |
| **[`currency_field_formatter`](https://pub.dev/packages/currency_field_formatter)** | Exact cursor-tracking currency and financial input formatter. | `^1.1.0` |
| **[`ambient_backdrop_glow`](https://pub.dev/packages/ambient_backdrop_glow)** | Dynamic ambient background glow & fluid OKLab mesh gradients. | `^1.1.0` |
| **[`scratch_reveal`](https://pub.dev/packages/scratch_reveal)** | GPU-accelerated scratch cards with sub-ms bitmask area tracking. | `^1.1.0` |
| **[`offline_outbox`](https://pub.dev/packages/offline_outbox)** | Offline-first resilient transactional outbox and retry queue. | `^1.1.0` |
| **[`cron_schedule`](https://pub.dev/packages/cron_schedule)** | Pure-Dart cron expression parser, predictor & fluent builder. | `^1.1.0` |
| **[`flutter_whisper`](https://pub.dev/packages/flutter_whisper)** | On-device speech-to-text transcription powered by whisper.cpp. | `^0.2.0` |
| **[`quote_painter`](https://pub.dev/packages/quote_painter)** | Canvas text styling with gradients, shadows, line badges & themes. | `^0.2.2` |
| **[`waveform_pro`](https://pub.dev/packages/waveform_pro)** | Audio waveform visualizer with discrete bars, splines & live buffer. | `^1.1.2` |

---

## 📄 License

This package is licensed under the [Apache-2.0 License](LICENSE).
