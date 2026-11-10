/// The app window on Linux, macOS and Windows behind one [AppWindow]
/// interface, window_manager (on nativeapi) underneath: its size and minimum
/// size, full screen, always on top, taskbar and title bar, showing and
/// focusing it, the resize and full screen events.
///
/// Apps use it instead of window_manager: [appWindowCurrent] answers null
/// where there is no such window (the web, mobile, `flutter test`), where
/// `AppWindowMemory` (`app_window_memory.dart`) stands in for tests.
///
/// [AppWindowSizeKeeper] saves the window size in a [KvStore] (an sdb prefs,
/// the app database) and restores it on the next launch,
/// [AppWindowSizeSaver] saves it while the app runs.
library;

export 'package:tekartik_prefs/kv_store.dart' show KvStore, KvStoreExt;

export 'src/app_window.dart' show AppWindow;
export 'src/app_window_factory.dart' show appWindowCurrent, appWindowSupported;
export 'src/app_window_size_keeper.dart'
    show AppWindowSizeKeeper, appWindowSizeKeyDefault;
export 'src/app_window_size_saver.dart' show AppWindowSizeSaver;
