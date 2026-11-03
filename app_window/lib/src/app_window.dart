import 'dart:async';
import 'dart:ui' show Size;

/// The app window on Linux, macOS and Windows.
///
/// From `appWindowCurrent()`, or an `AppWindowMemory` in tests. The calls are
/// synchronous like the native ones, a native failure throws: callers that
/// must never fail (a window issue must not prevent the app from starting)
/// catch.
///
/// [dispose] releases this object, the window itself stays.
abstract class AppWindow {
  /// The size of the window, its frame included.
  Size get size;

  /// Resize the window to [size], its frame included, [animate] where the
  /// platform can (macOS). It is never below [minimumSize].
  void setSize(Size size, {bool animate = false});

  /// The size the window cannot be resized below.
  Size get minimumSize;

  /// Set the size the window cannot be resized below.
  set minimumSize(Size value);

  /// True when the window is full screen.
  bool get isFullScreen;

  /// Make the window full screen (true) or not; [onFullScreenChanged]
  /// reports the change.
  set isFullScreen(bool value);

  /// True when the window stays above the other windows.
  bool get isAlwaysOnTop;

  /// Keep the window above the other windows (true) or not.
  set isAlwaysOnTop(bool value);

  /// True when the window shows in the taskbar (the dock on macOS).
  bool get isVisibleInTaskbar;

  /// Show the window in the taskbar (true) or not, a kiosk hides it.
  set isVisibleInTaskbar(bool value);

  /// True when the title bar is hidden.
  bool get isTitleBarHidden;

  /// Hide the title bar (true) or show it.
  set isTitleBarHidden(bool value);

  /// Show the window.
  void show();

  /// Give the window the focus (it comes to the front).
  void focus();

  /// The new size of the window each time it is resized, a stream of events
  /// while the user resizes it (broadcast).
  Stream<Size> get onResized;

  /// The full screen changes: true when entering full screen, false when
  /// leaving it, the ones asked through [isFullScreen] and the ones of the
  /// window manager (F11, the title bar button) (broadcast).
  Stream<bool> get onFullScreenChanged;

  /// Release this object: the streams close, the window stays.
  void dispose();
}
