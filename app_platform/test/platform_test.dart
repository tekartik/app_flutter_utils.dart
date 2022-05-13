import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_platform/platform.dart' as p;

void main() async {
  group('platform', () {
    test('isXxx vs flutter test', () {
      expect(p.isMacOS, isMacOS);
      expect(p.isWindows, isWindows);
      expect(p.isLinux, isLinux);
      expect(p.isWeb, isBrowser);
      // Never true in tests
      expect(p.isAndroid, isFalse);
      // Never true in tests
      expect(p.isIOS, isFalse);
    });
  });
}
