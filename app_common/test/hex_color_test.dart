import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_utils/hex_color.dart';

void main() {
  group('hex_color', () {
    test('fromHex', () {
      expect(HexColor.fromHex('FF0000'), const Color(0xffff0000));
      expect(HexColor.fromHex('#FFFF0000'), const Color(0xffff0000));
      expect(HexColor.fromHex('00FF00'), const Color(0xff00ff00));
      expect(HexColor.fromHex('0000FF'), const Color(0xff0000ff));
      expect(HexColor.fromHex('ffffffff'), Colors.white);
      expect(HexColor.fromHex('ff000000'), Colors.black);

      expect(HexColor.fromHexOrNull(''), isNull);
      expect(HexColor.fromHexOrNull('ffffffff'), Colors.white);
    });
    test('toHex', () {
      expect(const Color(0xffff0000).toHex(), '#ffff0000');
      expect(const Color(0xffff0000).toHex(leadingHashSign: false), 'ffff0000');
      expect(const Color(0xffff0000).toHex(noAlpha: true), '#ff0000');
      expect(const Color(0xff00ff00).toHex(), '#ff00ff00');
      expect(const Color(0xff0000ff).toHex(), '#ff0000ff');
      expect(Colors.white.toHex(), '#ffffffff');
      expect(Colors.black.toHex(), '#ff000000');
    });
  });
}
