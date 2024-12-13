import 'package:flutter/material.dart';

import 'material_color_compat.dart';

/// Generate a material color from a color
MaterialColor generateMaterialColor(Color color) =>
    generateMaterialColorCompat(color);
