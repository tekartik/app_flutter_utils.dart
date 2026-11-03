---
name: tekartik-app-flutter-window-setup
description: >-
  Use when a Flutter desktop app (Linux, macOS, Windows) manages its window:
  restoring or saving its size, a minimum size, full screen, a kiosk (always
  on top, hidden from the taskbar, no title bar), showing and focusing it,
  listening to resize or full screen changes. tekartik_app_flutter_window:
  appWindowCurrent() and AppWindow, AppWindowSizeKeeper (window size saved
  in a KvStore: sdb prefs, app database) and AppWindowSizeSaver from
  package:tekartik_app_flutter_window/app_window.dart, AppWindowMemory from
  app_window_memory.dart for tests; window_manager (0.6, nativeapi) is never
  used directly by apps.
---

# App window (tekartik_app_flutter_window)

One interface to the app window on Linux, macOS and Windows, `window_manager`
0.6 (on nativeapi) underneath. Apps depend on this package, never on
`window_manager` (its 0.6 API broke every 0.5 user: the next break is handled
here once).

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_flutter_window:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_window
      version: '>=0.1.0'
  ```

* `appWindowCurrent()` answers the app window, or null on the web, on
  mobile, under `flutter test` (no window, and the native library must not
  be loaded) and before the window exists. `appWindowSupported` is true on
  Linux, macOS and Windows.
* `AppWindow` is synchronous like nativeapi: `size`, `setSize(size,
  animate:)`, `minimumSize`, `isFullScreen`, `isAlwaysOnTop`,
  `isVisibleInTaskbar`, `isTitleBarHidden`, `show()`, `focus()`, the
  broadcast streams `onResized` (a stream of sizes while the user resizes,
  debounce before saving) and `onFullScreenChanged` (requests and the window
  manager's F11 / title bar button). A native failure throws: wrap startup
  calls in try/catch, a window issue must never prevent the app from
  starting.
* `dispose()` releases the object (the streams close), the window stays.
  Keep one per widget or service and dispose it with them.
* No `ensureInitialized` or `waitUntilReadyToShow` any more: set the
  properties, then `show()` and `focus()`. No runner setup either; the
  native core is compiled by a build hook, Linux build machines need
  `libgtk-3-dev libx11-dev libxi-dev`.
* Window size saved and restored: `AppWindowSizeKeeper(store: kvStore,
  key: 'app_window_size', minimumSize: ..., saveDelay: 500 ms)` keeps a json
  `{"width":..,"height":..}` in any `KvStore` (re-exported from
  tekartik_prefs): `getPrefsLightSdb(sdbFactory)` (tekartik_prefs_sdb, a
  dedicated sdb prefs), the app prefs, or the app database wrapped by
  `KvStore(getString:, setString:, remove:)` (tktoolsapp maps its `appMeta`
  sdb store `text` field). `await keeper.restoreAppWindow()` before `runApp`
  (minimum size, then the saved size), `AppWindowSizeSaver(keeper:, child:)`
  at the root saves after each resize; `read`, `write`, `restore(window)`,
  `save(window)`, `autoSave(window)` for custom flows. Sizes below
  `minimumSize` are never saved, a restored one is at least `minimumSize`.
* Kiosk: `isFullScreen = true`, `isAlwaysOnTop = true`,
  `isVisibleInTaskbar = false`, `isTitleBarHidden = true`, then `show()`,
  `focus()`; the reverse to leave it.
* Platform full screen across web, desktop and mobile (a player, a
  slideshow) is `tekartik_app_flutter_full_screen`, built on this package
  for desktop.
* Tests: `AppWindowMemory` holds the values, reports size changes (never
  below `minimumSize`) and full screen changes like the native window,
  `simulateResized` and `simulateFullScreenChanged` play the user and the
  window manager, `isShown`, `focusCount`, `isDisposed` record the calls.
