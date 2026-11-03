# tekartik_app_flutter_utils/app_window

The app window on Linux, macOS and Windows behind one `AppWindow` interface,
`window_manager` (0.6, on nativeapi) underneath, so that apps never use
`window_manager` directly: its size and minimum size, full screen, always on
top, taskbar and title bar, showing and focusing it, the resize and full
screen events.

## Setup

```yaml
dependencies:
  tekartik_app_flutter_window:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_window
    version: '>=0.1.0'
```

No runner setup: `window_manager` 0.6 needs none (Flutter 3.47 / Dart 3.13,
macOS 10.15). Its native core is compiled by a build hook (the Linux bundle
gets `lib/libcnativeapi.so`), so Linux build machines need `libgtk-3-dev
libx11-dev libxi-dev`.

## Usage

```dart
import 'package:tekartik_app_flutter_window/app_window.dart';

// Null on the web, on mobile, under flutter test, before the window exists.
final window = appWindowCurrent();
if (window != null) {
  try {
    window.minimumSize = const Size(240, 240);
    window.setSize(const Size(1000, 700));
  } catch (_) {
    // A window issue must never prevent the app from starting.
  }
  // While a widget is around.
  final subscription = window.onResized.listen((size) => save(size));
  // ...
  await subscription.cancel();
  window.dispose(); // releases this object, the window stays
}
```

A kiosk:

```dart
appWindowCurrent()
  ?..isFullScreen = true
  ..isAlwaysOnTop = true
  ..isVisibleInTaskbar = false
  ..isTitleBarHidden = true
  ..show()
  ..focus()
  ..dispose();
```

## Window size saved and restored

`AppWindowSizeKeeper` keeps the size in a `KvStore` (from tekartik_prefs,
re-exported): an sdb prefs (`getPrefsLightSdb(sdbFactory)` of
tekartik_prefs_sdb), the app prefs (a `PrefsLight` is a `KvStore`), or a
store of the app database wrapped by `KvStore(getString:, setString:,
remove:)`. The size is a json string under `key` (`app_window_size` by
default), never saved below `minimumSize`.

```dart
final keeper = AppWindowSizeKeeper(
  store: getPrefsLightSdb(sdbFactory),
  minimumSize: const Size(240, 240),
);

// Before runApp: the window opens at its last size.
await keeper.restoreAppWindow();

// Saved while the app runs (500 ms after the last resize event).
runApp(AppWindowSizeSaver(keeper: keeper, child: const MyApp()));
```

In tests, `AppWindowMemory` (`package:tekartik_app_flutter_window/app_window_memory.dart`)
keeps the values in memory, reports the changes like the native window and
simulates the user and the window manager (`simulateResized`,
`simulateFullScreenChanged`).
