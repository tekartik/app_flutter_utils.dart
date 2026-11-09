import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
    test('toHex alpha below 0x10', () {
      // The alpha takes 2 digits too: '5aabbcc' (no '#') was read back as
      // 0xf5aabbcc.
      expect(const Color(0x05aabbcc).toHex(), '#05aabbcc');
      expect(const Color(0x00ff0000).toHex(), '#00ff0000');
      expect(const Color(0x05aabbcc).toHex(leadingHashSign: false), '05aabbcc');
      for (var color in const [
        Color(0x05aabbcc),
        Color(0x00ff0000),
        Color(0x0f000000),
      ]) {
        expect(HexColor.fromHex(color.toHex()), color);
        expect(HexColor.fromHex(color.toHex(leadingHashSign: false)), color);
      }
      // A value written before (7 digits after the '#') still reads.
      expect(HexColor.fromHex('#5aabbcc'), const Color(0x05aabbcc));
    });
  });
}
