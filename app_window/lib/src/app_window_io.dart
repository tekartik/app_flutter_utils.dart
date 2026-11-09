import 'dart:async';
import 'dart:io';
import 'dart:ui' show Size;

import 'package:window_manager/window_manager.dart'
    show
        ListenerId,
        NativeSizeToSize,
        SizeToNative,
        TitleBarStyle,
        Window,
        WindowCloseRequestedEvent,
        WindowEnteredFullScreenEvent,
        WindowExitedFullScreenEvent,
        WindowManager,
        WindowResizedEvent;

import 'app_window.dart';

/// True on Linux, macOS and Windows, the platforms with an app window to
/// manage.
bool get appWindowSupported =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

/// True under `flutter test`, where there is no app window (and the native
/// library may not even be built).
bool get _isFlutterTest => Platform.environment.containsKey('FLUTTER_TEST');

/// The app window, null when there is none: not Linux, macOS or Windows,
/// under `flutter test`, no window yet. The caller disposes it.
AppWindow? appWindowCurrent() {
  if (!appWindowSupported || _isFlutterTest) {
    return null;
  }
  try {
    var window = WindowManager.instance.getCurrent();
    return window == null ? null : _AppWindowNative(window);
  } catch (_) {
    return null;
  }
}

/// The native window of window_manager (nativeapi).
class _AppWindowNative implements AppWindow {
  final Window _window;
  ListenerId? _listenerId;
  late final _resized = StreamController<Size>.broadcast(
    onListen: _listen,
    onCancel: _cancel,
  );
  late final _fullScreenChanged = StreamController<bool>.broadcast(
    onListen: _listen,
    onCancel: _cancel,
  );

  Future<bool> Function()? _closeRequestHandler;

  /// True while [close] closes the window: its close request is let through.
  var _closing = false;

  _AppWindowNative(this._window);

  /// The window events are listened to while a stream is, or while a
  /// [closeRequestHandler] is set.
  void _listen() {
    _listenerId ??= _window.addListener((event) {
      switch (event) {
        case WindowCloseRequestedEvent(:final request):
          var handler = _closeRequestHandler;
          if (_closing || handler == null) {
            _closing = false;
            break;
          }
          // Held, then closed if the handler says so.
          request.cancel();
          unawaited(_askClose(handler));
        case WindowResizedEvent():
          _resized.add(event.newSize.toSize());
        case WindowEnteredFullScreenEvent():
          _fullScreenChanged.add(true);
        case WindowExitedFullScreenEvent():
          _fullScreenChanged.add(false);
        default:
          break;
      }
    });
  }

  Future<void> _askClose(Future<bool> Function() handler) async {
    bool ok;
    try {
      ok = await handler();
    } catch (_) {
      // A failing handler must not keep the window open for ever.
      ok = true;
    }
    if (ok) {
      close();
    }
  }

  void _cancel() {
    if (_resized.hasListener ||
        _fullScreenChanged.hasListener ||
        _closeRequestHandler != null) {
      return;
    }
    var listenerId = _listenerId;
    _listenerId = null;
    if (listenerId != null) {
      _window.removeListener(listenerId);
    }
  }

  @override
  Size get size => _window.size.toSize();

  @override
  void setSize(Size size, {bool animate = false}) =>
      _window.setSize(size.toNative(), animate);

  @override
  Size get contentSize => _window.contentSize.toSize();

  @override
  set contentSize(Size value) => _window.contentSize = value.toNative();

  @override
  Size get minimumSize => _window.minimumSize.toSize();

  @override
  set minimumSize(Size value) => _window.minimumSize = value.toNative();

  @override
  bool get isFullScreen => _window.isFullScreen;

  @override
  set isFullScreen(bool value) => _window.isFullScreen = value;

  @override
  bool get isAlwaysOnTop => _window.isAlwaysOnTop;

  @override
  set isAlwaysOnTop(bool value) => _window.isAlwaysOnTop = value;

  @override
  bool get isVisibleInTaskbar => _window.isVisibleInTaskbar;

  @override
  set isVisibleInTaskbar(bool value) => _window.isVisibleInTaskbar = value;

  @override
  String get title => _window.title ?? '';

  @override
  set title(String value) => _window.title = value;

  @override
  bool get isTitleBarHidden => _window.titleBarStyle == TitleBarStyle.hidden;

  @override
  set isTitleBarHidden(bool value) => _window.titleBarStyle = value
      ? TitleBarStyle.hidden
      : TitleBarStyle.normal;

  @override
  void show() => _window.show();

  @override
  void focus() => _window.focus();

  @override
  Future<bool> Function()? get closeRequestHandler => _closeRequestHandler;

  @override
  set closeRequestHandler(Future<bool> Function()? value) {
    _closeRequestHandler = value;
    if (value != null) {
      _listen();
    } else {
      _cancel();
    }
  }

  @override
  bool close() {
    if (!Window.isCloseSupported()) {
      return false;
    }
    _closing = true;
    var closing = _window.close();
    if (!closing) {
      _closing = false;
    }
    return closing;
  }

  @override
  Stream<Size> get onResized => _resized.stream;

  @override
  Stream<bool> get onFullScreenChanged => _fullScreenChanged.stream;

  @override
  void dispose() {
    var listenerId = _listenerId;
    _listenerId = null;
    if (listenerId != null) {
      _window.removeListener(listenerId);
    }
    unawaited(_resized.close());
    unawaited(_fullScreenChanged.close());
    _window.dispose();
  }
}
