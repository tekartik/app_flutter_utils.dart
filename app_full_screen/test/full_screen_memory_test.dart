import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen_memory.dart';

void main() {
  group('full_screen_memory', () {
    test('set and toggle', () async {
      var fullScreen = PlatformFullScreenMemory();
      expect(fullScreen, isA<PlatformFullScreen>());
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      expect(fullScreen.supported, isTrue);
      expect(fullScreen.isFullScreen, isFalse);

      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
      // Same state again: no event.
      await fullScreen.setFullScreen(true);
      await fullScreen.toggleFullScreen();
      expect(fullScreen.isFullScreen, isFalse);
      await pumpEventQueue();
      expect(changes, [true, false]);
      expect(fullScreen.requests, [true, true, false]);
      fullScreen.dispose();
    });
    test('simulate a platform change', () async {
      var fullScreen = PlatformFullScreenMemory();
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      fullScreen.simulateFullScreenChanged(true);
      expect(fullScreen.isFullScreen, isTrue);
      // Escape: not asked for.
      fullScreen.simulateFullScreenChanged(false);
      fullScreen.simulateFullScreenChanged(false);
      expect(fullScreen.isFullScreen, isFalse);
      await pumpEventQueue();
      expect(changes, [true, false]);
      expect(fullScreen.requests, isEmpty);
      fullScreen.dispose();
    });
    test('unsupported', () async {
      var fullScreen = PlatformFullScreenMemory(supported: false);
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isFalse);
      expect(fullScreen.requests, [true]);
      await pumpEventQueue();
      expect(changes, isEmpty);
      fullScreen.dispose();
    });
    test('dispose closes onChanged', () async {
      var fullScreen = PlatformFullScreenMemory();
      var done = false;
      fullScreen.onChanged.listen((_) {}, onDone: () => done = true);
      fullScreen.dispose();
      await pumpEventQueue();
      expect(done, isTrue);
      // Ignored after dispose.
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
    });
  });
}
