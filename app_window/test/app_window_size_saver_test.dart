import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_window/app_window.dart';
import 'package:tekartik_app_flutter_window/app_window_memory.dart';

import 'memory_kv_store.dart';

void main() {
  testWidgets('AppWindowSizeSaver saves while shown', (tester) async {
    var keeper = AppWindowSizeKeeper(store: memoryKvStore());
    var window = AppWindowMemory();
    await tester.pumpWidget(
      AppWindowSizeSaver(
        keeper: keeper,
        window: window,
        child: const SizedBox(),
      ),
    );
    window.simulateResized(const Size(1000, 750));
    await tester.pump(keeper.saveDelay);
    expect(await tester.runAsync(keeper.read), const Size(1000, 750));
    await tester.pumpWidget(const SizedBox());
    // Not its window: not disposed.
    expect(window.isDisposed, isFalse);
  });

  testWidgets('AppWindowSizeSaver without an app window', (tester) async {
    // flutter test: no app window, nothing happens.
    await tester.pumpWidget(
      AppWindowSizeSaver(
        keeper: AppWindowSizeKeeper(store: memoryKvStore()),
        child: const SizedBox(),
      ),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
