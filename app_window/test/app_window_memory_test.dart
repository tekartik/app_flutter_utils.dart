import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';
import 'package:tekartik_app_flutter_window/app_window_memory.dart';

void main() {
  group('AppWindowMemory', () {
    test('defaults', () {
      AppWindow window = AppWindowMemory();
      expect(window.size, const Size(800, 600));
      expect(window.minimumSize, Size.zero);
      expect(window.isFullScreen, isFalse);
      expect(window.isAlwaysOnTop, isFalse);
      expect(window.isVisibleInTaskbar, isTrue);
      expect(window.isTitleBarHidden, isFalse);
      expect(window.title, isEmpty);
    });

    test('title', () {
      AppWindow window = AppWindowMemory()..title = 'Claude · sqflite';
      expect(window.title, 'Claude · sqflite');
    });

    test('size, never below the minimum size, changes reported', () {
      var window = AppWindowMemory(size: const Size(400, 300));
      var sizes = <Size>[];
      window.onResized.listen(sizes.add);
      window.setSize(const Size(500, 400));
      window.setSize(const Size(500, 400));
      window.minimumSize = const Size(600, 200);
      window.setSize(const Size(100, 100));
      window.simulateResized(const Size(700, 500));
      expect(sizes, const [
        Size(500, 400),
        // Grown to the minimum width.
        Size(600, 400),
        Size(600, 200),
        Size(700, 500),
      ]);
      expect(window.size, const Size(700, 500));
    });

    test('full screen, changes reported', () {
      var window = AppWindowMemory();
      var changes = <bool>[];
      window.onFullScreenChanged.listen(changes.add);
      window.isFullScreen = true;
      window.isFullScreen = true;
      // F11
      window.simulateFullScreenChanged(false);
      expect(changes, [true, false]);
      expect(window.isFullScreen, isFalse);
    });

    test('close request: asked, the window stays or closes', () async {
      var window = AppWindowMemory();
      // No handler: closes.
      expect(await window.simulateCloseRequest(), isTrue);
      expect(window.isClosed, isTrue);
      window = AppWindowMemory();
      var answer = false;
      var asked = 0;
      window.closeRequestHandler = () async {
        asked++;
        return answer;
      };
      expect(await window.simulateCloseRequest(), isFalse);
      expect(window.isClosed, isFalse);
      answer = true;
      expect(await window.simulateCloseRequest(), isTrue);
      expect(window.isClosed, isTrue);
      expect(asked, 2);
      // close: not asked.
      window = AppWindowMemory()..closeRequestHandler = () async => false;
      expect(window.close(), isTrue);
      expect(window.isClosed, isTrue);
    });

    test('kiosk properties, show, focus, dispose', () async {
      var window = AppWindowMemory()
        ..isAlwaysOnTop = true
        ..isVisibleInTaskbar = false
        ..isTitleBarHidden = true
        ..show()
        ..focus();
      expect(window.isAlwaysOnTop, isTrue);
      expect(window.isVisibleInTaskbar, isFalse);
      expect(window.isTitleBarHidden, isTrue);
      expect(window.isShown, isTrue);
      expect(window.focusCount, 1);
      var done = window.onResized.toList();
      window.dispose();
      expect(window.isDisposed, isTrue);
      expect(await done, isEmpty);
    });
  });
}
