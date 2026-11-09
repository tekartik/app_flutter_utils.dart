## 0.1.2

- `AppWindow.title` (get and set): what the window switchers and the title
  bar show.
- `AppWindow.closeRequestHandler`: asked when the user closes the window
  (its close button, Alt+F4), the window stays open when it answers false
  (a confirmation first); `AppWindow.close()` closes it without asking.
  `AppWindowMemory.simulateCloseRequest()`.

## 0.1.1

- `AppWindow.contentSize` (get and set, the title bar excluded).
  `AppWindowSizeKeeper` keeps the content size: `setSize` before the window
  is shown counted the title bar as content on Linux, the window grew by
  its title bar at each launch (a size saved before is read as a content
  size, the window is one title bar taller once). `AppWindowMemory`
  `titleBarHeight`.

## 0.1.0

- Initial version: `AppWindow` (size, setSize, minimumSize, isFullScreen,
  isAlwaysOnTop, isVisibleInTaskbar, isTitleBarHidden, show, focus,
  onResized, onFullScreenChanged, dispose) from `appWindowCurrent()`,
  `window_manager` >= 0.6.0 (nativeapi) underneath on Linux, macOS and
  Windows, null elsewhere and under `flutter test`. `AppWindowMemory` for
  tests.
- `AppWindowSizeKeeper` saves the window size in a `KvStore`
  (tekartik_prefs, re-exported: an sdb prefs, the app database) and restores
  it (`restore`, `restoreAppWindow`, `save`, debounced `autoSave`), never
  below its `minimumSize`; `AppWindowSizeSaver` saves it while in the tree. Covers the window_manager uses of tktoolsapp (size saved and
  restored), tekartik_app_flutter_full_screen and the kiosk apps.
