import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';

/// Generate a MaterialColor from a Color.
MaterialColor generateMaterialColorCompat(Color color) {
  return MaterialColor(color.compatValue, {
    50: tintColorCompat(color, 0.9),
    100: tintColorCompat(color, 0.8),
    200: tintColorCompat(color, 0.6),
    300: tintColorCompat(color, 0.4),
    400: tintColorCompat(color, 0.2),
    500: color,
    600: shadeColorCompat(color, 0.1),
    700: shadeColorCompat(color, 0.2),
    800: shadeColorCompat(color, 0.3),
    900: shadeColorCompat(color, 0.4),
  });
}

/// Tint a color by a factor.
int tintValueCompat(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

/// Tint a color by a factor.
Color tintColorCompat(Color color, double factor) => Color.fromRGBO(
  tintValueCompat(color.compatRed, factor),
  tintValueCompat(color.compatGreen, factor),
  tintValueCompat(color.compatBlue, factor),
  1,
);

/// Shade a color by a factor.
int shadeValueCompat(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

/// Shade a color by a factor.
Color shadeColorCompat(Color color, double factor) => Color.fromRGBO(
  shadeValueCompat(color.compatRed, factor),
  shadeValueCompat(color.compatGreen, factor),
  shadeValueCompat(color.compatBlue, factor),
  1,
);
