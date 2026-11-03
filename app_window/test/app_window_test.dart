@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';

void main() {
  test('appWindowSupported', () {
    expect(
      appWindowSupported,
      Platform.isLinux || Platform.isMacOS || Platform.isWindows,
    );
  });

  test('no app window under flutter test', () {
    // There is none, and the native library must not even be loaded.
    expect(appWindowCurrent(), isNull);
  });
}
