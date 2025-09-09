import 'package:flutter/material.dart';

/// Flutter extension for color compatibility
extension TekartikColorFlutterCompatExt on Color {
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

  /// Alpha
  int get compatAlpha => _floatToInt8(a);
}
