import 'dart:ui';
import 'color_compat.dart';

String _toHex(int value) {
  return value.toRadixString(16).padLeft(2, '0');
}

/// Flutter extension for color compatibility
extension HexColor on Color {
  /// String is in the format 'aabbcc' or 'ffaabbcc' with an optional leading '#'.
  static Color fromHex(String hexString) {
    return fromHexOrNull(hexString)!;
  }

  /// String is in the format 'aabbcc' or 'ffaabbcc' with an optional leading '#'.
  static Color? fromHexOrNull(String? hexString) {
    final buffer = StringBuffer();
    if (hexString == null) {
      return null;
    }
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    var value = int.tryParse(buffer.toString(), radix: 16);
    if (value == null) {
      return null;
    }
    return Color(value);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  ///
  /// Make it 6 digits if noAlpha is true
  String toHex({bool leadingHashSign = true, bool? noAlpha}) =>
      '${leadingHashSign ? '#' : ''}'
      '${((noAlpha ?? false) ? '' : compatAlpha.toRadixString(16))}'
      '${_toHex(compatRed)}'
      '${_toHex(compatGreen)}'
      '${_toHex(compatBlue)}';
}
