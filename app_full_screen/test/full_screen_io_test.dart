@TestOn('vm')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';
import 'package:tekartik_app_flutter_full_screen/src/full_screen_io.dart';

const _windowManagerChannel = MethodChannel('window_manager');

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// What the native side sends when the window manager changes state.
Future<void> _sendWindowEvent(String eventName) async {
  await _messenger.handlePlatformMessage(
    _windowManagerChannel.name,
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('onEvent', {'eventName': eventName}),
    ),
    (_) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('full_screen_io desktop', () {
    late List<MethodCall> calls;
    setUp(() {
      calls = [];
      _messenger.setMockMethodCallHandler(_windowManagerChannel, (call) async {
        calls.add(call);
        return null;
      });
    });
    tearDown(() {
      _messenger.setMockMethodCallHandler(_windowManagerChannel, null);
    });

    test('setFullScreen', () async {
      var fullScreen = createPlatformFullScreenIo(desktop: true);
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);
      expect(fullScreen.supported, isTrue);
      expect(fullScreen.isFullScreen, isFalse);

      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isTrue);
      expect(calls.map((call) => call.method), [
        'ensureInitialized',
        'setFullScreen',
      ]);
      expect(calls.last.arguments, {'isFullScreen': true});

      // Same state again: the plugin is called, no event.
      await fullScreen.setFullScreen(true);
      await fullScreen.setFullScreen(false);
      expect(calls.last.arguments, {'isFullScreen': false});
      await fullScreen.toggleFullScreen();
      expect(fullScreen.isFullScreen, isTrue);
      await pumpEventQueue();
      expect(changes, [true, false, true]);
      // Initialized once.
      expect(
        calls.where((call) => call.method == 'ensureInitialized').length,
        1,
      );
      fullScreen.dispose();
    });

    test('window manager events', () async {
      var fullScreen = createPlatformFullScreenIo(desktop: true);
      var changes = <bool>[];
      fullScreen.onChanged.listen(changes.add);

      await _sendWindowEvent('enter-full-screen');
      expect(fullScreen.isFullScreen, isTrue);
      await _sendWindowEvent('leave-full-screen');
      expect(fullScreen.isFullScreen, isFalse);
      // Unrelated event.
      await _sendWindowEvent('focus');
      await pumpEventQueue();
      expect(changes, [true, false]);
      expect(calls, isEmpty);

      fullScreen.dispose();
      // No longer listening.
      await _sendWindowEvent('enter-full-screen');
      expect(fullScreen.isFullScreen, isFalse);
    });

    test('plugin error', () async {
      _messenger.setMockMethodCallHandler(_windowManagerChannel, (call) async {
        calls.add(call);
        throw PlatformException(code: 'test');
      });
      var fullScreen = createPlatformFullScreenIo(desktop: true);
      await fullScreen.setFullScreen(true);
      expect(fullScreen.isFullScreen, isFalse);
      // The initialization is retried.
      await fullScreen.setFullScreen(true);
      expect(
        calls.where((call) => call.method == 'ensureInitialized').length,
        2,
      );
      fullScreen.dispose();
    });
  });

  group('full_screen_io without the plugin', () {
    test('missing plugin', () async {
      // flutter test has no window_manager plugin: MissingPluginException,
      // caught, nothing changes.
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
