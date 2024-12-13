import 'dart:math';

import 'package:flutter/material.dart';

extension TekartikColorFlutterExt on Color {
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  int get compatValue {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  /// Red component as an int.
  int get compatRed => _floatToInt8(r);

  /// Green component as an int.
  int get compatGreen => _floatToInt8(g);

  /// Blue component as an int.
  int get compatBlue => _floatToInt8(b);
}

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
    1);

/// Shade a color by a factor.
int shadeValueCompat(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

/// Shade a color by a factor.
Color shadeColorCompat(Color color, double factor) => Color.fromRGBO(
    shadeValueCompat(color.compatRed, factor),
    shadeValueCompat(color.compatGreen, factor),
    shadeValueCompat(color.compatBlue, factor),
    1);
