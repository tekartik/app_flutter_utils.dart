import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show Size, VoidCallback;

import 'package:tekartik_prefs/kv_store.dart';

import 'app_window.dart';
import 'app_window_factory.dart';

/// The key of the window size in the store, by default.
const appWindowSizeKeyDefault = 'app_window_size';

/// Saves the size of the app window in a [KvStore] and restores it on the
/// next launch.
///
/// The store is any [KvStore]: an sdb prefs (`getPrefsLightSdb(sdbFactory)`
/// of tekartik_prefs_sdb), the app prefs (a `PrefsLight` is a [KvStore]), a
/// store of the app database wrapped by
/// `KvStore(getString: ..., setString: ..., remove: ...)`. The size is a json
/// string (`{"width":1000.0,"height":700.0}`) under [key].
///
/// A size below [minimumSize] is never saved (it would make the app unusable
/// on the next launch) and the restored size is at least [minimumSize].
class AppWindowSizeKeeper {
  /// Where the size is kept.
  final KvStore store;

  /// The key of the size in [store].
  final String key;

  /// The minimum size of the window, also the floor of a restored size.
  final Size minimumSize;

  /// How long after the last resize event [autoSave] saves.
  final Duration saveDelay;

  /// Keeps the size in [store] under [key] ([appWindowSizeKeyDefault] by
  /// default), the window never below [minimumSize] (none by default), saved
  /// [saveDelay] after a resize (500 ms by default).
  AppWindowSizeKeeper({
    required this.store,
    this.key = appWindowSizeKeyDefault,
    this.minimumSize = Size.zero,
    this.saveDelay = const Duration(milliseconds: 500),
  });

  /// The saved size, null when none or invalid.
  Future<Size?> read() async {
    try {
      var text = await store.getString(key);
      if (text != null) {
        var map = jsonDecode(text);
        if (map is Map) {
          var width = map['width'];
          var height = map['height'];
          if (width is num && height is num && width > 0 && height > 0) {
            return Size(width.toDouble(), height.toDouble());
          }
        }
      }
    } catch (_) {
      // Not a size, as if none was saved.
    }
    return null;
  }

  /// Save [size], unless empty or below [minimumSize].
  Future<void> write(Size size) async {
    if (size.isEmpty ||
        size.width < minimumSize.width ||
        size.height < minimumSize.height) {
      return;
    }
    await store.setString(
      key,
      jsonEncode({'width': size.width, 'height': size.height}),
    );
  }

  /// Set [minimumSize] on [window] (when not zero), then the saved size (at
  /// least [minimumSize]).
  ///
  /// Never throws: a window issue must never prevent the app from starting.
  Future<void> restore(AppWindow window) async {
    try {
      if (minimumSize != Size.zero) {
        window.minimumSize = minimumSize;
      }
      var size = await read();
      if (size != null) {
        window.setSize(
          Size(
            max(size.width, minimumSize.width),
            max(size.height, minimumSize.height),
          ),
        );
      }
    } catch (_) {
      // No window (or no window manager), never mind.
    }
  }

  /// [restore] on the app window (`appWindowCurrent()`), nothing where there
  /// is none. Call it before `runApp` so that the window opens at its size.
  Future<void> restoreAppWindow() async {
    var window = appWindowCurrent();
    if (window != null) {
      try {
        await restore(window);
      } finally {
        window.dispose();
      }
    }
  }

  /// Save the current size of [window]. Never throws.
  Future<void> save(AppWindow window) async {
    try {
      await write(window.size);
    } catch (_) {
      // No window, the store is gone: the next launch uses the default size.
    }
  }

  /// Save the size of [window] [saveDelay] after each resize (a resize is a
  /// stream of events, only the last one is saved) until the returned
  /// function is called.
  VoidCallback autoSave(AppWindow window) {
    Timer? timer;
    var subscription = window.onResized.listen((size) {
      timer?.cancel();
      timer = Timer(saveDelay, () => unawaited(save(window)));
    });
    return () {
      timer?.cancel();
      unawaited(subscription.cancel());
    };
  }
}
