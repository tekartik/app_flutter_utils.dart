import 'dart:async';

import 'package:flutter/services.dart' show SystemUiMode;

/// Options of `createPlatformFullScreen`.
///
/// Only the mobile system ui modes for now: the web and desktop
/// implementations take no option.
class PlatformFullScreenOptions {
  /// The system ui mode applied on Android and iOS when entering full screen.
  ///
  /// Defaults to [SystemUiMode.immersiveSticky] (bars hidden, a swipe shows
  /// them briefly). Not [SystemUiMode.manual], which needs overlays.
  final SystemUiMode mobileFullScreenMode;

  /// The system ui mode restored on Android and iOS when leaving full screen.
  ///
  /// Defaults to [SystemUiMode.edgeToEdge], the Flutter default on recent
  /// Android versions.
  final SystemUiMode mobileNormalMode;

  /// Options with the given mobile modes, both optional.
  const PlatformFullScreenOptions({
    this.mobileFullScreenMode = SystemUiMode.immersiveSticky,
    this.mobileNormalMode = SystemUiMode.edgeToEdge,
  });
}

/// Platform full screen: the browser full screen api on the web, the window
/// manager on desktop, the immersive mode on mobile.
///
/// Created by `createPlatformFullScreen()`, one per screen that needs it,
/// after the widgets binding is initialized (from a `State`), and
/// [dispose]d with it.
abstract class PlatformFullScreen {
  /// True when the platform can take over the screen at all.
  ///
  /// False on unsupported platforms and in a browser page that does not allow
  /// full screen (an iframe without `allowfullscreen`).
  bool get supported;

  /// True when the platform is currently full screen.
  ///
  /// Not the same as the app being full screen: the browser drops out on
  /// escape without going through [setFullScreen], see [onChanged].
  bool get isFullScreen;

  /// Fires with the new [isFullScreen] value when the platform full screen
  /// state changes, including changes not asked for (escape in the browser,
  /// the window manager on desktop).
  ///
  /// A broadcast stream, closed by [dispose].
  Stream<bool> get onChanged;

  /// Ask for ([fullScreen] true) or leave (false) the platform full screen.
  ///
  /// A refusal is not an error: the browser refuses outside a user gesture
  /// and the plugin may be missing (tests), the state simply does not change
  /// and the returned future completes normally.
  Future<void> setFullScreen(bool fullScreen);

  /// [setFullScreen] with the opposite of [isFullScreen].
  Future<void> toggleFullScreen();

  /// Release the platform listeners and close [onChanged].
  void dispose();
}

/// Base for [PlatformFullScreen] implementations: keeps the state, emits
/// [onChanged] only when it changes, implements [toggleFullScreen].
///
/// An implementation calls [setFullScreenState] after the platform applied a
/// change, asked for or not.
abstract class PlatformFullScreenBase implements PlatformFullScreen {
  final _changes = StreamController<bool>.broadcast();
  var _fullScreen = false;

  @override
  bool get isFullScreen => _fullScreen;

  @override
  Stream<bool> get onChanged => _changes.stream;

  /// Record the platform state [fullScreen]; emits [onChanged] when it
  /// differs from the current one, nothing otherwise.
  ///
  /// For implementations (and the memory fake), not for users.
  void setFullScreenState(bool fullScreen) {
    if (_fullScreen != fullScreen) {
      _fullScreen = fullScreen;
      if (!_changes.isClosed) {
        _changes.add(fullScreen);
      }
    }
  }

  @override
  Future<void> toggleFullScreen() => setFullScreen(!isFullScreen);

  @override
  void dispose() {
    _changes.close();
  }
}
