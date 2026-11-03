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
