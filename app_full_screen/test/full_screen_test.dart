import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('full_screen', () {
    test('create', () async {
      var fullScreen = createPlatformFullScreen();
      expect(fullScreen.supported, isA<bool>());
      expect(fullScreen.isFullScreen, isFalse);
      // Never throws: without the plugin (flutter test) or without a user
      // gesture (browser) the request is refused and the state unchanged.
      await fullScreen.setFullScreen(true);
      await fullScreen.setFullScreen(false);
      expect(fullScreen.isFullScreen, isFalse);
      fullScreen.dispose();
    });
    test('options', () {
      const options = PlatformFullScreenOptions();
      expect(options.mobileFullScreenMode, SystemUiMode.immersiveSticky);
      expect(options.mobileNormalMode, SystemUiMode.edgeToEdge);
      var fullScreen = createPlatformFullScreen(options: options);
      fullScreen.dispose();
    });
  });
}
