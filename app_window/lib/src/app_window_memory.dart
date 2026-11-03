import 'dart:async';
import 'dart:math';
import 'dart:ui' show Size;

import 'app_window.dart';

/// An [AppWindow] in memory for tests and previews.
///
/// The properties are plain values. Like the native window, a size change
/// (never below [minimumSize]) is reported by [onResized] and a full screen
/// change by [onFullScreenChanged]; [simulateResized] and
/// [simulateFullScreenChanged] report the changes made by the user or the
/// window manager.
class AppWindowMemory implements AppWindow {
  Size _size;
  Size _minimumSize;
  bool _isFullScreen;
  final _resized = StreamController<Size>.broadcast(sync: true);
  final _fullScreenChanged = StreamController<bool>.broadcast(sync: true);

  /// A window of [size] (800x600 by default), not full screen, not on top,
  /// in the taskbar, with its title bar ([titleBarHeight] high, none by
  /// default: the content is the whole window).
  AppWindowMemory({
    this._size = const Size(800, 600),
    this._minimumSize = Size.zero,
    this._isFullScreen = false,
    this.isAlwaysOnTop = false,
    this.isVisibleInTaskbar = true,
    this.isTitleBarHidden = false,
    this.titleBarHeight = 0,
  });

  /// The height of the frame above the content ([size] minus [contentSize]).
  final double titleBarHeight;

  @override
  bool isAlwaysOnTop;

  @override
  bool isVisibleInTaskbar;

  @override
  bool isTitleBarHidden;

  /// True once [show] was called.
  var isShown = false;

  /// How many times [focus] was called.
  var focusCount = 0;

  /// True once [dispose] was called.
  var isDisposed = false;

  @override
  Size get size => _size;

  @override
  void setSize(Size size, {bool animate = false}) => _resize(size);

  @override
  Size get contentSize =>
      Size(_size.width, max(0, _size.height - titleBarHeight));

  @override
  set contentSize(Size value) =>
      _resize(Size(value.width, value.height + titleBarHeight));

  /// Resize to [size] (at least [minimumSize]), reported when it changes.
  void _resize(Size size) {
    var newSize = Size(
      max(size.width, _minimumSize.width),
      max(size.height, _minimumSize.height),
    );
    if (newSize != _size) {
      _size = newSize;
      _resized.add(newSize);
    }
  }

  @override
  Size get minimumSize => _minimumSize;

  /// Set the minimum size, the window grows to it when smaller.
  @override
  set minimumSize(Size value) {
    _minimumSize = value;
    _resize(_size);
  }

  @override
  bool get isFullScreen => _isFullScreen;

  @override
  set isFullScreen(bool value) => simulateFullScreenChanged(value);

  @override
  void show() => isShown = true;

  @override
  void focus() => focusCount++;

  @override
  Stream<Size> get onResized => _resized.stream;

  @override
  Stream<bool> get onFullScreenChanged => _fullScreenChanged.stream;

  /// The user resized the window to [size] (at least [minimumSize]).
  void simulateResized(Size size) => _resize(size);

  /// The window manager made the window full screen (F11, the title bar
  /// button) or left it, reported when it changes.
  void simulateFullScreenChanged(bool isFullScreen) {
    if (isFullScreen != _isFullScreen) {
      _isFullScreen = isFullScreen;
      _fullScreenChanged.add(isFullScreen);
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    unawaited(_resized.close());
    unawaited(_fullScreenChanged.close());
  }
}
