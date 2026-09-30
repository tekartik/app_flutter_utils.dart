@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

void main() {
  group('full_screen_web', () {
    test('create', () async {
      var fullScreen = createPlatformFullScreen();
      expect(fullScreen.supported, isA<bool>());
      expect(fullScreen.isFullScreen, isFalse);
      // Refused without a user gesture (or granted on a permissive test
      // browser): no error either way.
      await fullScreen.setFullScreen(true);
      await fullScreen.setFullScreen(false);
      expect(fullScreen.isFullScreen, isFalse);
      fullScreen.dispose();
    });
  });
}
