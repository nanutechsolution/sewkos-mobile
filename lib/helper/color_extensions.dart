import 'package:flutter/material.dart';

extension ColorShade on Color {
  /// Menggelapkan warna hingga [amount] (0.0–1.0)
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }
}
