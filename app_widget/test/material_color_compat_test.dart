import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_widget/src/material_color_compat.dart';
import 'package:tekartik_common_utils/hex_utils.dart';

extension on int {
  List<int> toUint8List32() {
    return <int>[
      (this & 0xFF000000) >> 24,
      (this & 0x00FF0000) >> 16,
      (this & 0x0000FF00) >> 8,
      (this & 0x000000FF) >> 0
    ];
  }

  String toHexString32() {
    return '0x${toHexString(toUint8List32())}';
  }
}

extension on MaterialColor {
  List<int> toIntList() {
    return <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        .map((int value) => this[value]!.compatValue)
        .toList();
  }
}

Future<void> main() async {
  group('material_color_compat', () {
    test('compat', () {
      for (var color in [Colors.orange, Colors.green]) {
        // ignore: deprecated_member_use
        expect(color.compatRed, color.red);
        // ignore: deprecated_member_use
        expect(color.compatGreen, color.green);
        // ignore: deprecated_member_use
        expect(color.compatBlue, color.blue);
      }
    });

    test('materialColorCompat', () {
      var color = generateMaterialColorCompat(Colors.orange);
      expect(
          color.toIntList(),
          <int>[
            0xFFFFF5E6,
            0xFFFFEACC,
            0xFFFFD699,
            0xFFFFC166,
            0xFFFFAD33,
            0xFFFF9800,
            0xFFE58900,
            0xFFCC7A00,
            0xFFB26A00,
            0xFF995B00
          ],
          reason: color
              .toIntList()
              .map((int value) => value.toHexString32())
              .join(','));
      //expect(color, Colors.orange);
    });
  });
}
