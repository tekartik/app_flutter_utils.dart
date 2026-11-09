# tekartik_app_flutter_window

The app window of a Flutter desktop app (Linux, macOS, Windows) behind one
`AppWindow` interface: its size and content size, minimum size, full screen,
always on top, taskbar, title bar, title, show and focus, a close
confirmation, the resize and full screen events. `window_manager` 0.6 (on
nativeapi) is underneath: apps use this package, never `window_manager`
directly. `AppWindowSizeKeeper` saves the window size and restores it at the
next launch.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_window:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_window
```

A desktop app that opens at its last size (complete app in
[example/main.dart](example/main.dart)):

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';

/// [store] keeps the size: your prefs or database (see below).
Future<void> runDesktopApp(KvStore store, Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  var keeper = AppWindowSizeKeeper(
    store: store,
    minimumSize: const Size(400, 300),
  );
  // Before runApp: the window opens at its last size.
  await keeper.restoreAppWindow();
  // Saved 500 ms after each resize while the app runs.
  runApp(AppWindowSizeSaver(keeper: keeper, child: app));
}
```

Platforms: Linux, macOS (10.15+) and Windows, Flutter 3.47 / Dart 3.13 at
least. No runner setup. The native core is compiled by a build hook (the
Linux bundle gets `lib/libcnativeapi.so`): Linux build machines (CI included)
need `libgtk-3-dev libx11-dev libxi-dev`. On the web, Android and iOS there
is no app window: `appWindowCurrent()` is null and the keeper and the saver
do nothing, so the same `main()` runs everywhere.

## The window

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';

/// The app window, null on the web, on mobile and under `flutter test`.
AppWindow? setUpAppWindow(Future<bool> Function() confirmQuit) {
  var window = appWindowCurrent();
  if (window != null) {
    try {
      window
        ..minimumSize = const Size(400, 300)
        ..title = 'My app';
    } catch (_) {
      // A window issue must never prevent the app from starting.
    }
    // Asked when the user closes the window, it stays open on false.
    window.closeRequestHandler = confirmQuit;
  }
  // Keep it while the app runs (its handler and streams live on it).
  return window;
}

/// A kiosk: full screen, above the others, no taskbar entry, no title bar.
void enterKiosk(AppWindow window) {
  window
    ..isFullScreen = true
    ..isAlwaysOnTop = true
    ..isVisibleInTaskbar = false
    ..isTitleBarHidden = true
    ..show()
    ..focus();
}
```

- `size` / `setSize(size)`: the whole window, its frame included.
  `contentSize` (get and set): where the app draws, the title bar excluded.
- `onResized` (sizes while the user resizes) and `onFullScreenChanged`
  (`isFullScreen` set by the app, F11, the title bar button) are broadcast
  streams.
- `closeRequestHandler`: asked when the user closes the window (close
  button, Alt+F4); the window closes when it completes with true (or
  throws), stays open on false. `close()` closes it without asking.
- `dispose()` releases the object (its streams close, its handler goes), the
  window stays.

## Window size saved and restored

`AppWindowSizeKeeper` keeps the size as json (`{"width":..,"height":..}`)
under `key` (`app_window_size` by default) in a `KvStore` (from
tekartik_prefs, re-exported): an sdb prefs (`getPrefsLightSdb(sdbFactory)` of
tekartik_prefs_sdb), the app prefs (a `PrefsLight` is a `KvStore`), or a
store of the app database wrapped by `KvStore(getString:, setString:,
remove:)`.

- `restoreAppWindow()` (before `runApp`): the minimum size, then the saved
  size, never below the minimum size. It never throws.
- `AppWindowSizeSaver(keeper:, child:)` saves 500 ms (`saveDelay`) after the
  last resize event while it is in the tree; nothing is saved while the
  window is below `minimumSize`.
- `read`, `write`, `restore(window)`, `save(window)`, `autoSave(window)` for
  other flows.

The content size is kept, not the whole window: set before the window is
shown, the whole size is not exact on Linux (the window would grow by its
title bar at each launch).

## Common pitfalls

- `appWindowCurrent()` answers a new object at each call: keep the one that
  holds your `closeRequestHandler` and stream subscriptions, dispose it with
  them.
- A native failure throws: wrap the startup calls (the keeper already
  does), a window issue must not stop the app.
- Entering full screen is a resize too: an app closed while full screen
  reopens at the size of the screen (not full screen).
- `window_manager` itself: do not depend on it in the app, its next API
  break is handled here once.

## Testing

`AppWindowMemory` (`package:tekartik_app_flutter_window/app_window_memory.dart`)
keeps the values in memory, reports the changes like the native window and
plays the user and the window manager: `simulateResized`,
`simulateFullScreenChanged`, `simulateCloseRequest`; `isShown`, `focusCount`,
`isClosed`, `isDisposed` record the calls. Under `flutter test`
`appWindowCurrent()` is null (the native library is not even loaded).

Agent skill:
[tekartik-app-flutter-window-setup](skills/tekartik-app-flutter-window-setup/SKILL.md).
