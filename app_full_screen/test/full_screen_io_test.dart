@TestOn('vm')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';
import 'package:tekartik_app_flutter_full_screen/src/full_screen_io.dart';

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// A desktop window recording the requests, failing on demand.
class _FakeDesktopWindow implements PlatformFullScreenDesktopWindow {
  final requests = <bool>[];
  var listenCount = 0;
  var disposed = false;

  /// Thrown by every call when set.
  Object? error;
  ValueChanged<bool>? _onFullScreenChanged;

  bool get listening => _onFullScreenChanged != null;

  /// What the window manager reports (F11, the title bar button).
  void simulateFullScreenChanged(bool fullScreen) =>
      _onFullScreenChanged?.call(fullScreen);

  @override
  void setFullScreen(bool fullScreen) {
    if (error != null) {
      throw error!;
    }
    requests.add(fullScreen);
  }

  @override
  VoidCallback listen(ValueChanged<bool> onFullScreenChanged) {
    listenCount++;
    if (error != null) {
      throw error!;
    }
    _onFullScreenChanged = onFullScreenChanged;
    return () => _onFullScreenChanged = null;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('full_screen_io desktop', () {
    late _FakeDesktopWindow window;
    setUp(() {
      window = _FakeDesktopWindow();
    });

    test('setFullScreen', () async {
      var fullScreen = createPlatformFullScreenIo(
        desktop: true,
        desktopWindow: window,
      );
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      expect(fullScreen.supported, isTrue);
      expect(fullScreen.isFullScreen, isFalse);

      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
      expect(window.requests, [true]);

      // Same state again: the window is called, no event.
      await fullScreen.setFullScreen(true);
      await fullScreen.setFullScreen(false);
      expect(window.requests, [true, true, false]);
      await fullScreen.toggleFullScreen();
      expect(fullScreen.isFullScreen, isTrue);
      await pumpEventQueue();
      expect(changes, [true, false, true]);
      // Listening once.
      expect(window.listenCount, 1);
      fullScreen.dispose();
      expect(window.listening, isFalse);
      expect(window.disposed, isTrue);
    });

    test('window manager events', () async {
      var fullScreen = createPlatformFullScreenIo(
        desktop: true,
        desktopWindow: window,
      );
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);

      window.simulateFullScreenChanged(true);
      expect(fullScreen.isFullScreen, isTrue);
      window.simulateFullScreenChanged(false);
      expect(fullScreen.isFullScreen, isFalse);
      await pumpEventQueue();
      expect(changes, [true, false]);
      expect(window.requests, isEmpty);

      fullScreen.dispose();
      // No longer listening.
      window.simulateFullScreenChanged(true);
      expect(fullScreen.isFullScreen, isFalse);
    });

    test('window error', () async {
      window.error = StateError('test');
      var fullScreen = createPlatformFullScreenIo(
        desktop: true,
        desktopWindow: window,
      );
      expect(window.listenCount, 1);
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isFalse);
      // Listening is retried on each request until it works.
      expect(window.listenCount, 2);
      window.error = null;
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
      expect(window.listenCount, 3);
      await fullScreen.setFullScreen(false);
      expect(window.listenCount, 3);
      window.simulateFullScreenChanged(true);
      expect(fullScreen.isFullScreen, isTrue);
      fullScreen.dispose();
    });
  });

  group('full_screen_io without a window', () {
    test('flutter test', () async {
      // flutter test has no app window: the error is caught, nothing changes.
      var fullScreen = createPlatformFullScreenIo(desktop: true);
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isFalse);
      fullScreen.dispose();
    });
  });

  group('full_screen_io mobile', () {
    late List<MethodCall> calls;
    setUp(() {
      calls = [];
      _messenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        calls.add(call);
        return null;
      });
    });
    tearDown(() {
      _messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('setFullScreen', () async {
      var fullScreen = createPlatformFullScreenIo(desktop: false);
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      expect(fullScreen.supported, isTrue);

      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
      expect(calls.single.method, 'SystemChrome.setEnabledSystemUIMode');
      expect(calls.single.arguments, 'SystemUiMode.immersiveSticky');

      await fullScreen.setFullScreen(false);
      expect(fullScreen.isFullScreen, isFalse);
      expect(calls.last.arguments, 'SystemUiMode.edgeToEdge');
      await pumpEventQueue();
      expect(changes, [true, false]);
      fullScreen.dispose();
    });

    test('options', () async {
      var fullScreen = createPlatformFullScreenIo(
        desktop: false,
        options: const PlatformFullScreenOptions(
          mobileFullScreenMode: SystemUiMode.immersive,
          mobileNormalMode: SystemUiMode.leanBack,
        ),
      );
      await fullScreen.setFullScreen(true);
      expect(calls.last.arguments, 'SystemUiMode.immersive');
      await fullScreen.setFullScreen(false);
      expect(calls.last.arguments, 'SystemUiMode.leanBack');
      fullScreen.dispose();
    });

    test('platform error', () async {
      _messenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        throw PlatformException(code: 'test');
      });
      var fullScreen = createPlatformFullScreenIo(desktop: false);
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isFalse);
      fullScreen.dispose();
    });
  });
}
