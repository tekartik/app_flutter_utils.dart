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
PlatformFullScreen createPlatformFullScreenIo({
  PlatformFullScreenOptions? options,
  bool? desktop,
}) => PlatformFullScreenIo(
  options: options ?? const PlatformFullScreenOptions(),
  desktop: desktop ?? _isDesktop,
);

bool get _isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

/// Io implementation: `window_manager` on desktop (which also reports the
/// changes made by the window manager itself), `SystemChrome` on mobile.
///
/// Every platform failure (plugin missing in tests, refused) is logged and
/// leaves the state unchanged.
class PlatformFullScreenIo extends PlatformFullScreenBase {
  /// The mobile modes.
  final PlatformFullScreenOptions options;

  /// True for the window manager path, false for the mobile one.
  final bool desktop;

  late final _windowListener = _WindowEvents(this);
  var _listening = false;
  Future<void>? _initialized;

  /// See [createPlatformFullScreenIo].
  PlatformFullScreenIo({required this.options, required this.desktop}) {
    _listen();
  }

  /// Hear the window manager changes (F11, the title bar button).
  ///
  /// Needs the widgets binding: retried on the first request when created
  /// before it.
  void _listen() {
    if (desktop && !_listening) {
      try {
        windowManager.addListener(_windowListener);
        _listening = true;
      } catch (e) {
        debugPrint('full screen: $e');
      }
    }
  }

  @override
  bool get supported => true;

  Future<void> _ensureInitialized() {
    _listen();
    return _initialized ??= windowManager.ensureInitialized();
  }

  @override
  Future<void> setFullScreen(bool fullScreen) async {
    try {
      if (desktop) {
        await _ensureInitialized();
        await windowManager.setFullScreen(fullScreen);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          fullScreen ? options.mobileFullScreenMode : options.mobileNormalMode,
        );
      }
    } catch (e) {
      // Retry the initialization next time rather than caching a failure.
      _initialized = null;
      debugPrint('full screen: $e');
      return;
    }
    setFullScreenState(fullScreen);
  }

  @override
  void dispose() {
    if (_listening) {
      windowManager.removeListener(_windowListener);
      _listening = false;
    }
    super.dispose();
  }
}

class _WindowEvents extends WindowListener {
  final PlatformFullScreenIo owner;

  _WindowEvents(this.owner);

  @override
  void onWindowEnterFullScreen() => owner.setFullScreenState(true);

  @override
  void onWindowLeaveFullScreen() => owner.setFullScreenState(false);
}
