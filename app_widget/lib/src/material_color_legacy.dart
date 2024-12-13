// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

/// TO remove when tester
/// Generate a material color from a color
MaterialColor generateMaterialColorLegacy(Color color) {
  return MaterialColor(color.value, {
    50: tintColorLegacy(color, 0.9),
    100: tintColorLegacy(color, 0.8),
    200: tintColorLegacy(color, 0.6),
    300: tintColorLegacy(color, 0.4),
    400: tintColorLegacy(color, 0.2),
    500: color,
    600: shadeColorLegacy(color, 0.1),
    700: shadeColorLegacy(color, 0.2),
    800: shadeColorLegacy(color, 0.3),
    900: shadeColorLegacy(color, 0.4),
  });
}

/// Tint a color by a factor
int tintValueLegacy(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

/// Tint a color by a factor
Color tintColorLegacy(Color color, double factor) => Color.fromRGBO(
    tintValueLegacy(color.red, factor),
    tintValueLegacy(color.green, factor),
    tintValueLegacy(color.blue, factor),
    1);

/// Shade a color by a factor
int shadeValueLegacy(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColorLegacy(Color color, double factor) => Color.fromRGBO(
    shadeValueLegacy(color.red, factor),
    shadeValueLegacy(color.green, factor),
    shadeValueLegacy(color.blue, factor),
    1);
