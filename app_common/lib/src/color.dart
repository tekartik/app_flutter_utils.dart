import 'package:material_ui/material_ui.dart';

import 'material_color_compat.dart';

/// Generate a material color from a color
MaterialColor generateMaterialColor(Color color) =>
    generateMaterialColorCompat(color);

/// dark/light helper
extension TekartikColorFlutterExt on Color {
  /// True if the color is dark: luminance (`0.299 r + 0.587 g + 0.114 b`, the
  /// components from 0 to 1) below 0.5, alpha ignored. Use it to pick a light
  /// or dark foreground.
  bool get isDark {
    // Standard luminance formula
    final brightness = (0.299 * r + 0.587 * g + 0.114 * b);

    return brightness < .5; // threshold (0..1 scale)
  }
}
