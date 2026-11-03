import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'full_screen.dart';

/// The window manager on desktop, the immersive mode on mobile.
PlatformFullScreen createPlatformFullScreen({
  PlatformFullScreenOptions? options,
}) => createPlatformFullScreenIo(options: options);

/// The io implementation with the platform choice exposed for tests:
/// [desktop] true forces the window manager path, false the mobile system ui
/// mode path; null (the default) detects it from the platform.
///
/// [desktopWindow] replaces the app window of `window_manager` (tests).
PlatformFullScreen createPlatformFullScreenIo({
  PlatformFullScreenOptions? options,
  bool? desktop,
  PlatformFullScreenDesktopWindow? desktopWindow,
}) => PlatformFullScreenIo(
  options: options ?? const PlatformFullScreenOptions(),
  desktop: desktop ?? _isDesktop,
  desktopWindow: desktopWindow,
);

bool get _isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

/// True under `flutter test`, where there is no app window.
bool get _isFlutterTest => Platform.environment.containsKey('FLUTTER_TEST');

/// The desktop window made full screen: the app window of `window_manager`
/// by default, a fake in tests.
abstract class PlatformFullScreenDesktopWindow {
  /// Make the window full screen ([fullScreen] true) or not.
  ///
  /// Throws when the window is not available.
  void setFullScreen(bool fullScreen);

  /// Report the full screen changes of the window, including the window
  /// manager ones (F11, the title bar button), until the returned function
  /// is called.
  ///
  /// Throws when the window is not available.
  VoidCallback listen(ValueChanged<bool> onFullScreenChanged);

  /// Release the window.
  void dispose();
}

/// The app window of `window_manager` (nativeapi), looked up on first use.
class _NativeDesktopWindow implements PlatformFullScreenDesktopWindow {
  Window? _window;

  Window get _current {
    if (_isFlutterTest) {
      // No app window, and the native library may not even be built.
      throw UnsupportedError('no app window under flutter test');
    }
    return _window ??=
        WindowManager.instance.getCurrent() ??
        (throw StateError('no current window'));
  }

  @override
  void setFullScreen(bool fullScreen) {
    _current.isFullScreen = fullScreen;
  }

  @override
  VoidCallback listen(ValueChanged<bool> onFullScreenChanged) {
    var window = _current;
    var listenerId = window.addListener((event) {
      switch (event) {
        case WindowEnteredFullScreenEvent():
          onFullScreenChanged(true);
        case WindowExitedFullScreenEvent():
          onFullScreenChanged(false);
        default:
          break;
      }
    });
    return () => window.removeListener(listenerId);
  }

  @override
  void dispose() {
    _window?.dispose();
    _window = null;
  }
}

/// Io implementation: `window_manager` on desktop (which also reports the
/// changes made by the window manager itself), `SystemChrome` on mobile.
///
/// Every platform failure (no window in tests, refused) is logged and leaves
/// the state unchanged.
class PlatformFullScreenIo extends PlatformFullScreenBase {
  /// The mobile modes.
  final PlatformFullScreenOptions options;

  /// True for the window manager path, false for the mobile one.
  final bool desktop;

  final PlatformFullScreenDesktopWindow _desktopWindow;
  VoidCallback? _cancelListen;

  /// See [createPlatformFullScreenIo].
  PlatformFullScreenIo({
    required this.options,
    required this.desktop,
    PlatformFullScreenDesktopWindow? desktopWindow,
  }) : _desktopWindow = desktopWindow ?? _NativeDesktopWindow() {
    _listen();
  }

  /// Hear the window manager changes (F11, the title bar button).
  ///
  /// Retried on the next request when the window is not available yet.
  void _listen() {
    if (desktop && _cancelListen == null) {
      try {
        _cancelListen = _desktopWindow.listen(setFullScreenState);
      } catch (e) {
        debugPrint('full screen: $e');
      }
    }
  }

  @override
  bool get supported => true;

  @override
  Future<void> setFullScreen(bool fullScreen) async {
    try {
      if (desktop) {
        _listen();
        _desktopWindow.setFullScreen(fullScreen);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          fullScreen ? options.mobileFullScreenMode : options.mobileNormalMode,
        );
      }
    } catch (e) {
      debugPrint('full screen: $e');
      return;
    }
    setFullScreenState(fullScreen);
  }

  @override
  void dispose() {
    _cancelListen?.call();
    _cancelListen = null;
    if (desktop) {
      _desktopWindow.dispose();
    }
    super.dispose();
  }
}
