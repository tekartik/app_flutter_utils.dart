@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_platform/platform.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';

void main() async {
  group('platform_io', () {
    test('isXxx vs flutter test', () {});
    test('isXxx', () {
      if (Platform.isMacOS) {
        expect(p.isMacOS, isTrue);
      } else if (Platform.isLinux) {
        expect(p.isMacOS, isFalse);
        expect(p.isLinux, isTrue);
        expect(p.isWindows, isFalse);
      } else if (Platform.isWindows) {
        expect(p.isMacOS, isFalse);
        expect(p.isLinux, isFalse);
        expect(p.isWindows, isTrue);
      }
      print(jsonPretty(platformContext.toMap())); // ignore: avoid_print
    });
  });
}
