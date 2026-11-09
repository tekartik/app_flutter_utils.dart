---
name: tekartik-app-flutter-window-setup
description: >-
  Use when a Flutter desktop app (Linux, macOS, Windows) manages its window:
  restoring or saving its size, a minimum size, full screen, a kiosk (always
  on top, hidden from the taskbar, no title bar), its title, a confirmation
  before the window closes, showing and focusing it, listening to resize or
  full screen changes. tekartik_app_flutter_window: appWindowCurrent() and
  AppWindow (title, closeRequestHandler, close), AppWindowSizeKeeper (window
  size saved in a KvStore: sdb prefs, app database) and AppWindowSizeSaver
  from package:tekartik_app_flutter_window/app_window.dart, AppWindowMemory
  from app_window_memory.dart for tests; window_manager (0.6, nativeapi) is
  never used directly by apps.
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
  animate:)` (the whole window), `contentSize` (get and set, the title bar
  excluded, exact before the window is shown), `minimumSize`, `isFullScreen`, `isAlwaysOnTop`,
  `isVisibleInTaskbar`, `isTitleBarHidden`, `show()`, `focus()`, the
  broadcast streams `onResized` (a stream of sizes while the user resizes,
  debounce before saving) and `onFullScreenChanged` (requests and the window
  manager's F11 / title bar button). A native failure throws: wrap startup
  calls in try/catch, a window issue must never prevent the app from
  starting.
* `title` (get and set): what the title bar and the window switchers show.
* `closeRequestHandler` (`Future<bool> Function()?`): asked when the user
  closes the window (close button, Alt+F4, the window menu); the window
  closes when it completes with true (or throws), stays open on false (ask
  "Quit?" first). `close()` closes the window without asking it (returns
  false where the platform cannot close it). Not available on mobile.
* `dispose()` releases the object (the streams close, its
  `closeRequestHandler` goes), the window stays. `appWindowCurrent()` answers
  a new object at each call: keep the one holding the handler and the
  subscriptions for as long as they are needed, dispose it with them.
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
  `save(window)`, `autoSave(window)` for custom flows. The content size is
  kept (`setSize` before the window is shown counts its title bar as content
  on Linux: the window would grow at each launch). Nothing is saved while
  the window is below `minimumSize`, a restored size is at least
  `minimumSize`. Entering full screen is a resize too: an app closed while
  full screen reopens at the size of the screen (not full screen).
* Kiosk: `isFullScreen = true`, `isAlwaysOnTop = true`,
  `isVisibleInTaskbar = false`, `isTitleBarHidden = true`, then `show()`,
  `focus()`; the reverse to leave it.
* Platform full screen across web, desktop and mobile (a player, a
  slideshow) is `tekartik_app_flutter_full_screen`, built on this package
  for desktop.
* Tests: `AppWindowMemory` holds the values, reports size changes (never
  below `minimumSize`) and full screen changes like the native window,
  `simulateResized`, `simulateFullScreenChanged` and `simulateCloseRequest`
  play the user and the window manager, `isShown`, `focusCount`, `isClosed`,
  `isDisposed` record the calls. `AppWindowMemory(titleBarHeight: 47)` makes
  `size` and `contentSize` differ as on Linux.
* Complete app: `example/main.dart` of the package.

## Examples

### Main of a desktop app

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';

/// [store]: an sdb prefs, the app prefs, a store of the app database.
Future<void> runDesktopApp(
  KvStore store,
  Widget app, {
  required Future<bool> Function() confirmQuit,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  var keeper = AppWindowSizeKeeper(
    store: store,
    minimumSize: const Size(400, 300),
  );
  // Before runApp: the window opens at its last size (never throws).
  await keeper.restoreAppWindow();
  // Null on the web, on mobile and under flutter test. Kept for the life of
  // the app: the handler lives on this object.
  var window = appWindowCurrent();
  if (window != null) {
    try {
      window.title = 'My app';
    } catch (_) {
      // A window issue must never prevent the app from starting.
    }
    window.closeRequestHandler = confirmQuit;
  }
  runApp(AppWindowSizeSaver(keeper: keeper, window: window, child: app));
}
```

### Testing with the memory window

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';
import 'package:tekartik_app_flutter_window/app_window_memory.dart';
import 'package:tekartik_prefs/prefs_light.dart';

void main() {
  test('size kept', () async {
    var keeper = AppWindowSizeKeeper(store: PrefsMemory());
    var window = AppWindowMemory();
    window.simulateResized(const Size(1000, 700));
    await keeper.save(window);
    var next = AppWindowMemory();
    await keeper.restore(next);
    expect(next.size, const Size(1000, 700));
  });

  test('close confirmation', () async {
    var window = AppWindowMemory()..closeRequestHandler = () async => false;
    expect(await window.simulateCloseRequest(), isFalse);
    expect(window.isClosed, isFalse);
  });
}
```
