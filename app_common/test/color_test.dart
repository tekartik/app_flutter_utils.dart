import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';

Future<void> main() async {
  group('color', () {
    // TO remove when not compiling any more
    test('isDark', () {
      expect(const Color(0xFFFFca00).isDark, isFalse);
      expect(const Color(0xFFFF0000).isDark, isTrue);
      expect(Colors.blue.isDark, isTrue);
    });
  });
}
