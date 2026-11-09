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

  /// The size of the window content (where the app draws), its frame (the
  /// title bar) excluded.
  ///
  /// Unlike [setSize], setting it is exact before the window is shown (on
  /// Linux the frame is only known once the window is shown): the size to
  /// save and restore.
  Size get contentSize;

  /// Resize the window so that its content is [value].
  set contentSize(Size value);

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

  /// The title of the window, what the window switchers (Alt+Tab, the
  /// overview) and the title bar show; empty when none.
  String get title;

  /// Set the title of the window to [value].
  set title(String value);

  /// True when the title bar is hidden.
  bool get isTitleBarHidden;

  /// Hide the title bar (true) or show it.
  set isTitleBarHidden(bool value);

  /// Show the window.
  void show();

  /// Give the window the focus (it comes to the front).
  void focus();

  /// Asked when the user closes the window (its close button, Alt+F4, the
  /// window menu): the window closes when it completes with true, stays
  /// open when false (a question to the user first, "End the running
  /// sessions?"). Null (the default) lets the window close as usual. It is
  /// not asked for a [close]; it is ignored where the platform cannot hold
  /// a close request.
  Future<bool> Function()? get closeRequestHandler;

  /// Set the [closeRequestHandler], null to remove it.
  set closeRequestHandler(Future<bool> Function()? value);

  /// Close the window, [closeRequestHandler] not asked (the app ends with
  /// its last window). Returns false when the platform cannot close it (the
  /// caller may end the app itself).
  bool close();

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
