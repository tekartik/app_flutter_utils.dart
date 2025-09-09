import 'package:flutter/material.dart';

import 'material_color_compat.dart';

/// Generate a material color from a color
MaterialColor generateMaterialColor(Color color) =>
    generateMaterialColorCompat(color);

/// dark/light helper
extension TekartikColorFlutterExt on Color {
  /// True if the color is dark
  bool get isDark {
    // Standard luminance formula
    final brightness = (0.299 * r + 0.587 * g + 0.114 * b);

    return brightness < .5; // threshold (0–255 scale)
  }
}
