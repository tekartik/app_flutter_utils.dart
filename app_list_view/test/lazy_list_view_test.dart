import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

Future<void> pumpAsync() => Future<void>.delayed(Duration.zero);

void main() {
  group('LazyListController', () {
    test('future basic logic', () async {
      var data = List.generate(10, (i) => 'item $i');
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
        pageSize: 3,
      );

      await pumpAsync();
      expect(controller.isInitialized, isTrue);
      expect(controller.totalCount, 10);

      // Request items and check lazy-loading
      expect(controller.getItem(0), isNull); // Loading started
      await pumpAsync();
      expect(controller.getItem(0), 'item 0');
      expect(controller.getItem(1), 'item 1');
      expect(controller.getItem(2), 'item 2');
      expect(controller.getItem(3), isNull); // Page 1 loading started
      await pumpAsync();
      expect(controller.getItem(3), 'item 3');

      // Past the end
      expect(controller.getItem(10), isNull);
      controller.dispose();
    });

    test('future without count infers total', () async {
      var data = List.generate(7, (i) => i);
      var controller = LazyListController<int>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        pageSize: 3,
      );

      await pumpAsync();
      expect(controller.isInitialized, isTrue);
      expect(controller.totalCount, isNull);

      controller.getItem(6); // last page (6..8), only one item
      await pumpAsync();
      expect(controller.getItem(6), 6);
      expect(controller.totalCount, 7);
      controller.dispose();
    });

    test('stream items and count', () async {
      var countController = StreamController<int>();
      var pageControllers = <int, StreamController<List<String>>>{};
      var controller = LazyListController<String>.stream(
        watchItems: (offset, limit) =>
            (pageControllers[offset] ??= StreamController<List<String>>())
                .stream,
        watchCount: () => countController.stream,
        pageSize: 2,
      );

      expect(controller.isInitialized, isFalse);
      countController.add(4);
      await pumpAsync();
      expect(controller.isInitialized, isTrue);
      expect(controller.totalCount, 4);

      expect(controller.getItem(0), isNull); // Watching page 0 started
      await pumpAsync();
      pageControllers[0]!.add(['a', 'b']);
      await pumpAsync();
      expect(controller.getItem(0), 'a');
      expect(controller.getItem(1), 'b');

      // Live update of an already loaded page
      pageControllers[0]!.add(['a2', 'b2']);
      await pumpAsync();
      expect(controller.getItem(0), 'a2');

      // Count update
      countController.add(2);
      await pumpAsync();
      expect(controller.totalCount, 2);

      controller.dispose();
      await countController.close();
      for (var pageController in pageControllers.values) {
        await pageController.close();
      }
    });

    test('refresh resets state', () async {
      var data = ['a', 'b', 'c'];
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
        pageSize: 2,
      );
      await pumpAsync();
      controller.getItem(0);
      await pumpAsync();
      expect(controller.getItem(0), 'a');

      data = ['x', 'y'];
      controller.refresh();
      expect(controller.isInitialized, isFalse);
      await pumpAsync();
      expect(controller.totalCount, 2);
      controller.getItem(0);
      await pumpAsync();
      expect(controller.getItem(0), 'x');
      controller.dispose();
    });

    test('evicts pages outside the window (stream)', () async {
      var listened = <int>[];
      var cancelled = <int>[];
      var pageControllers = <int, StreamController<List<String>>>{};
      StreamController<List<String>> pageController(int offset) =>
          pageControllers[offset] ??= StreamController<List<String>>(
            onListen: () => listened.add(offset),
            onCancel: () => cancelled.add(offset),
          );

      var controller = LazyListController<String>.stream(
        watchItems: (offset, limit) => pageController(offset).stream,
        watchCount: () => Stream.value(100),
        pageSize: 2,
        pageWindowMargin: 0,
      );
      await pumpAsync();
      expect(controller.totalCount, 100);

      controller.getItem(0);
      controller.getItem(1);
      await pumpAsync();
      expect(listened, [0]);
      pageControllers[0]!.add(['a', 'b']);
      await pumpAsync();
      // hasItem/loadedItems do not mark the index as requested.
      expect(controller.hasItem(0), isTrue);
      expect(controller.loadedItems[0], 'a');

      // Scroll far away, page 0 falls out of the window: it must be dropped
      // and, above all, stop being watched.
      controller.getItem(50);
      controller.getItem(51);
      await pumpAsync();
      expect(cancelled, [0]);
      expect(listened, [0, 50]);
      expect(controller.hasItem(0), isFalse);
      expect(controller.hasItem(1), isFalse);

      controller.dispose();
      for (var pageController in pageControllers.values) {
        await pageController.close();
      }
    });

    test('evicts pages outside the window (future)', () async {
      var data = List.generate(100, (i) => 'item $i');
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
        pageSize: 10,
        pageWindowMargin: 1,
      );
      await pumpAsync();
      controller.getItem(0);
      await pumpAsync();
      expect(controller.hasItem(0), isTrue);

      controller.getItem(90);
      await pumpAsync();
      await pumpAsync();
      expect(controller.hasItem(90), isTrue);
      // Only the window (pages 8, 9, 10 -> 9 and 10 exist) is kept.
      expect(controller.hasItem(0), isFalse);
      expect(controller.loadedItems.length, 10);
      controller.dispose();
    });

    test('keeps every page with a null window margin', () async {
      var data = List.generate(100, (i) => 'item $i');
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
        pageSize: 10,
        pageWindowMargin: null,
      );
      await pumpAsync();
      controller.getItem(0);
      await pumpAsync();
      controller.getItem(90);
      await pumpAsync();
      await pumpAsync();
      expect(controller.hasItem(0), isTrue);
      expect(controller.hasItem(90), isTrue);
      controller.dispose();
    });

    test('hasEverLoadedItems survives eviction, reset by refresh', () async {
      var data = List.generate(100, (i) => 'item $i');
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
        pageSize: 10,
        pageWindowMargin: 0,
      );
      await pumpAsync();
      expect(controller.hasEverLoadedItems, isFalse);
      controller.getItem(0);
      await pumpAsync();
      expect(controller.hasEverLoadedItems, isTrue);

      controller.getItem(90);
      await pumpAsync();
      // Page 0 has been evicted, but the list is known to have had data.
      expect(controller.hasItem(0), isFalse);
      expect(controller.hasEverLoadedItems, isTrue);

      controller.refresh();
      expect(controller.hasEverLoadedItems, isFalse);
      controller.dispose();
    });

    test('coalesces notifications of a single change', () async {
      var pageControllers = <int, StreamController<List<String>>>{};
      var controller = LazyListController<String>.stream(
        watchItems: (offset, limit) =>
            (pageControllers[offset] ??= StreamController<List<String>>())
                .stream,
        watchCount: () => Stream.value(10),
        pageSize: 2,
      );
      await pumpAsync();
      controller.getItem(0);
      controller.getItem(2);
      controller.getItem(4);
      await pumpAsync();

      var notifications = 0;
      controller.addListener(() => notifications++);
      // One data change makes every watched page re-emit, the listeners must
      // only be notified once.
      pageControllers[0]!.add(['a', 'b']);
      pageControllers[2]!.add(['c', 'd']);
      pageControllers[4]!.add(['e', 'f']);
      await pumpAsync();
      expect(notifications, 1);
      expect(controller.getItem(0), 'a');
      expect(controller.getItem(4), 'e');

      controller.dispose();
      for (var pageController in pageControllers.values) {
        await pageController.close();
      }
    });

    test('watched count is not shrunk by a short page', () async {
      var countController = StreamController<int>();
      var pageControllers = <int, StreamController<List<String>>>{};
      var controller = LazyListController<String>.stream(
        watchItems: (offset, limit) =>
            (pageControllers[offset] ??= StreamController<List<String>>())
                .stream,
        watchCount: () => countController.stream,
        pageSize: 4,
      );
      countController.add(8);
      await pumpAsync();
      expect(controller.totalCount, 8);

      controller.getItem(4);
      await pumpAsync();
      // Last page is short (a delete happened), the watched count is
      // authoritative and re-emits on the same change: do not oscillate.
      pageControllers[4]!.add(['e', 'f']);
      await pumpAsync();
      expect(controller.totalCount, 8);

      countController.add(6);
      await pumpAsync();
      expect(controller.totalCount, 6);

      controller.dispose();
      await countController.close();
      for (var pageController in pageControllers.values) {
        await pageController.close();
      }
    });
  });

  group('LazyListView', () {
    testWidgets('displays items (future)', (tester) async {
      var data = List.generate(5, (i) => 'val $i');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              getItems: (offset, limit) async =>
                  data.skip(offset).take(limit).toList(),
              getCount: () async => data.length,
              pageSize: 2,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 50, child: Text(item)),
              itemLoadingBuilder: (context, index) =>
                  const SizedBox(height: 50, child: Text('loading...')),
            ),
          ),
        ),
      );

      // Initial load (count is fetched first)
      await tester.pumpAndSettle();

      expect(find.text('val 0'), findsOneWidget);
      expect(find.text('val 1'), findsOneWidget);
      expect(find.text('val 4'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 5)));

    testWidgets('global loadingBuilder until first data', (tester) async {
      var countCompleter = Completer<int>();
      var itemsCompleter = Completer<List<String>>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              getItems: (offset, limit) => itemsCompleter.future,
              getCount: () => countCompleter.future,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 50, child: Text(item)),
              loadingBuilder: (context) => const Text('global loading'),
            ),
          ),
        ),
      );

      // Shown before the count is known.
      expect(find.text('global loading'), findsOneWidget);

      countCompleter.complete(2);
      await tester.pump();
      // Count known (2) but no data yet, still globally loading.
      expect(find.text('global loading'), findsOneWidget);

      itemsCompleter.complete(['a', 'b']);
      await tester.pumpAndSettle();
      expect(find.text('global loading'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 5)));

    testWidgets('displays empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              getItems: (offset, limit) async => <String>[],
              getCount: () async => 0,
              itemBuilder: (context, item, index) => Text(item),
              emptyBuilder: (context) => const Text('empty'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('empty'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 5)));

    testWidgets('displays error state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              getItems: (offset, limit) async => <String>[],
              getCount: () async => throw StateError('count failed'),
              itemBuilder: (context, item, index) => Text(item),
              errorBuilder: (context, error, stackTrace) =>
                  Text('error: $error'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('count failed'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 5)));

    testWidgets('keeps the list when scrolled to unloaded pages', (
      tester,
    ) async {
      var data = List.generate(1000, (i) => 'val $i');
      var scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              getItems: (offset, limit) async =>
                  data.skip(offset).take(limit).toList(),
              getCount: () async => data.length,
              pageSize: 20,
              pageWindowMargin: 0,
              scrollController: scrollController,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 50, child: Text(item)),
              itemLoadingBuilder: (context, index) =>
                  const SizedBox(height: 50, child: Text('loading...')),
              loadingBuilder: (context) => const Text('global loading'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('val 0'), findsOneWidget);

      // Jump to item 500, its page is not loaded and the pages that were
      // loaded get evicted: the list (and so the scroll position) must be
      // kept, showing the item placeholders.
      scrollController.jumpTo(500 * 50.0);
      await tester.pump();
      expect(find.text('global loading'), findsNothing);
      await tester.pump();
      expect(find.text('global loading'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('global loading'), findsNothing);
      expect(find.text('val 500'), findsOneWidget);
      expect(find.text('val 0'), findsNothing);
      expect(scrollController.offset, 500 * 50.0);
      scrollController.dispose();
    }, timeout: const Timeout(Duration(seconds: 5)));

    testWidgets('updates on stream events', (tester) async {
      var pageControllers = <int, StreamController<List<String>>>{};
      var countController = StreamController<int>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyListView<String>(
              watchItems: (offset, limit) =>
                  (pageControllers[offset] ??= StreamController<List<String>>())
                      .stream,
              watchCount: () => countController.stream,
              pageSize: 10,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 50, child: Text(item)),
            ),
          ),
        ),
      );

      countController.add(2);
      await tester.pump();
      pageControllers[0]!.add(['one', 'two']);
      await tester.pump();

      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);

      // Live update
      pageControllers[0]!.add(['uno', 'dos']);
      await tester.pump();
      expect(find.text('uno'), findsOneWidget);
      expect(find.text('one'), findsNothing);

      await countController.close();
      for (var pageController in pageControllers.values) {
        await pageController.close();
      }
    }, timeout: const Timeout(Duration(seconds: 5)));
  });

  group('SliverLazyList', () {
    testWidgets('displays items in a CustomScrollView', (tester) async {
      var data = List.generate(3, (i) => 'sliver $i');
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async =>
            data.skip(offset).take(limit).toList(),
        getCount: () async => data.length,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 50, child: Text('header')),
                ),
                SliverLazyList<String>(
                  controller: controller,
                  itemBuilder: (context, item, index) =>
                      SizedBox(height: 50, child: Text(item)),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('header'), findsOneWidget);
      expect(find.text('sliver 0'), findsOneWidget);
      expect(find.text('sliver 2'), findsOneWidget);
      controller.dispose();
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}
