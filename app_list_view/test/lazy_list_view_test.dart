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
              loadingBuilder: (context, index) =>
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
    testWidgets(
      'displays items in a CustomScrollView',
      (tester) async {
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
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });
}
