import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';
import 'package:tekartik_app_flutter_window/app_window_memory.dart';

import 'memory_kv_store.dart';

void main() {
  group('AppWindowSizeKeeper', () {
    test('read, write', () async {
      var values = <String, String>{};
      var keeper = AppWindowSizeKeeper(
        store: memoryKvStore(values),
        minimumSize: const Size(240, 240),
      );
      expect(await keeper.read(), isNull);
      await keeper.write(const Size(800, 600.5));
      expect(values, {'app_window_size': '{"width":800.0,"height":600.5}'});
      expect(await keeper.read(), const Size(800, 600.5));
      // Below the minimum size, empty: not saved.
      await keeper.write(const Size(100, 600));
      await keeper.write(Size.zero);
      expect(await keeper.read(), const Size(800, 600.5));
      // Invalid: none.
      values['app_window_size'] = 'not json';
      expect(await keeper.read(), isNull);
      values['app_window_size'] = '{"width":-1,"height":600}';
      expect(await keeper.read(), isNull);
    });

    test('restore, save', () async {
      var store = memoryKvStore({'size': '{"width":100,"height":700}'});
      var keeper = AppWindowSizeKeeper(
        store: store,
        key: 'size',
        minimumSize: const Size(240, 240),
      );
      var window = AppWindowMemory();
      await keeper.restore(window);
      expect(window.minimumSize, const Size(240, 240));
      // At least the minimum size.
      expect(window.size, const Size(240, 700));
      window.simulateResized(const Size(1000, 800));
      await keeper.save(window);
      expect(await keeper.read(), const Size(1000, 800));
      // Nothing saved: the window keeps its size.
      window = AppWindowMemory();
      await AppWindowSizeKeeper(store: memoryKvStore()).restore(window);
      expect(window.size, const Size(800, 600));
    });

    test('autoSave, the last size of a resize', () async {
      var keeper = AppWindowSizeKeeper(
        store: memoryKvStore(),
        saveDelay: const Duration(milliseconds: 20),
      );
      var window = AppWindowMemory();
      var stop = keeper.autoSave(window);
      window.simulateResized(const Size(900, 700));
      window.simulateResized(const Size(1000, 750));
      expect(await keeper.read(), isNull);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(await keeper.read(), const Size(1000, 750));
      stop();
      window.simulateResized(const Size(500, 500));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(await keeper.read(), const Size(1000, 750));
    });

    test('restoreAppWindow without an app window', () async {
      // flutter test: no app window, nothing happens.
      await AppWindowSizeKeeper(store: memoryKvStore()).restoreAppWindow();
    });
  });
}
