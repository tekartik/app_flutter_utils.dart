import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

Future<void> pumpAsync() => Future<void>.delayed(Duration.zero);

void main() {
  group('LazyListController.refresh', () {
    test(
      'a page fetched before refresh does not overwrite fresh data',
      () async {
        var completers = <Completer<List<String>>>[];
        var controller = LazyListController<String>.future(
          getItems: (offset, limit) {
            var completer = Completer<List<String>>();
            completers.add(completer);
            return completer.future;
          },
          pageSize: 2,
        );
        await pumpAsync();
        controller.getItem(0); // Fetch before the refresh.
        controller.refresh();
        await pumpAsync();
        controller.getItem(0); // Fetch after the refresh.
        expect(completers.length, 2);
        completers[1].complete(['new0', 'new1']);
        await pumpAsync();
        expect(controller.getItem(0), 'new0');
        completers[0].complete(['old0', 'old1']);
        await pumpAsync();
        expect(controller.getItem(0), 'new0');
        controller.dispose();
      },
    );

    test(
      'a count fetched before refresh does not overwrite fresh data',
      () async {
        var completers = <Completer<int>>[];
        var controller = LazyListController<String>.future(
          getItems: (offset, limit) async => <String>[],
          getCount: () {
            var completer = Completer<int>();
            completers.add(completer);
            return completer.future;
          },
        );
        controller.refresh();
        expect(completers.length, 2);
        completers[1].complete(5);
        await pumpAsync();
        completers[0].complete(10);
        await pumpAsync();
        expect(controller.totalCount, 5);
        controller.dispose();
      },
    );
  });

  test('a watched page recovering from an error clears it', () async {
    var pageController = StreamController<List<String>>();
    var controller = LazyListController<String>.stream(
      watchItems: (offset, limit) => pageController.stream,
      watchCount: () => Stream.value(2),
      pageSize: 2,
    );
    await pumpAsync();
    controller.getItem(0);
    pageController.addError(StateError('failed'));
    await pumpAsync();
    expect(controller.error, isA<StateError>());
    pageController.add(['a', 'b']);
    await pumpAsync();
    expect(controller.error, isNull);
    expect(controller.getItem(0), 'a');
    controller.dispose();
    await pageController.close();
  });

  testWidgets('LazyListView parent rebuild with inline callbacks', (
    tester,
  ) async {
    var queries = 0;
    var data = List.generate(200, (i) => 'v$i');
    var scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return LazyListView<String>(
                getItems: (offset, limit) async {
                  queries++;
                  return data.skip(offset).take(limit).toList();
                },
                getCount: () async => data.length,
                pageSize: 20,
                itemExtent: 50,
                scrollController: scrollController,
                itemBuilder: (context, item, index) => Text(item),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    scrollController.jumpTo(5000);
    await tester.pumpAndSettle();
    expect(find.text('v100'), findsOneWidget);
    var queriesBefore = queries;
    rebuild(() {});
    await tester.pumpAndSettle();
    expect(queries, queriesBefore);
    expect(scrollController.offset, 5000);
    expect(find.text('v100'), findsOneWidget);
  });

  group('failed page', () {
    // SliverLazyList shows no error state: its rows kept asking for the
    // failed page, fetched again on every frame (60 fetches a second).
    testWidgets('SliverLazyList does not fetch it on every frame, retry does', (
      tester,
    ) async {
      var fetches = 0;
      var fail = true;
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async {
          fetches++;
          if (fail) {
            throw StateError('offline');
          }
          return List.generate(limit, (i) => 'item ${offset + i}');
        },
        getCount: () async => 100,
        pageSize: 20,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverLazyList<String>(
                  controller: controller,
                  // 50 px rows: the screen and its cache extent hold page 0.
                  itemExtent: 50,
                  itemBuilder: (context, item, index) => Text(item),
                  itemLoadingBuilder: (context, index) => const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
      Future<void> frames() async {
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }

      await frames();
      expect(fetches, 1);
      expect(controller.error, isA<StateError>());

      // Still failing: one fetch per retry.
      controller.retry();
      await frames();
      expect(fetches, 2);
      expect(controller.error, isA<StateError>());

      fail = false;
      controller.retry();
      await tester.pumpAndSettle();
      expect(fetches, 3);
      expect(controller.error, isNull);
      expect(find.text('item 0'), findsOneWidget);
    });

    test('retry restarts a failed watched page', () async {
      var watches = 0;
      var controller = LazyListController<String>.stream(
        watchItems: (offset, limit) {
          watches++;
          return watches == 1
              ? Stream.error(StateError('failed'))
              : Stream.value(['a', 'b']);
        },
        watchCount: () => Stream.value(2),
        pageSize: 2,
      );
      await pumpAsync();
      controller.getItem(0);
      await pumpAsync();
      expect(controller.error, isA<StateError>());
      controller.getItem(0);
      await pumpAsync();
      expect(watches, 1);
      controller.retry();
      expect(controller.error, isNull);
      controller.getItem(0);
      await pumpAsync();
      expect(watches, 2);
      expect(controller.getItem(0), 'a');
      controller.dispose();
    });

    test('retry fetches a failed count again', () async {
      var counts = 0;
      var controller = LazyListController<String>.future(
        getItems: (offset, limit) async => ['a', 'b'],
        getCount: () async {
          counts++;
          if (counts == 1) {
            throw StateError('count failed');
          }
          return 2;
        },
      );
      await pumpAsync();
      expect(controller.error, isA<StateError>());
      controller.retry();
      await pumpAsync();
      expect(counts, 2);
      expect(controller.error, isNull);
      expect(controller.totalCount, 2);
      controller.dispose();
    });
  });

  // On a scroll the list only builds (requests) the rows it exposes: the
  // window of kept pages was computed from these rows alone, evicting the
  // pages still on screen when pageSize * pageWindowMargin is smaller than
  // the rows laid out (here 30 on screen + the cache extent, pages of 10,
  // margin 2): the visible rows lost their items and pages were loaded 3 to
  // 5 times each.
  for (var stream in [false, true]) {
    testWidgets(
      'scrolling keeps the pages on screen (${stream ? 'stream' : 'future'})',
      (tester) async {
        var loads = <int, int>{};
        List<int> page(int offset, int limit) {
          loads[offset] = (loads[offset] ?? 0) + 1;
          return List.generate(limit, (i) => offset + i);
        }

        var controller = stream
            ? LazyListController<int>.stream(
                watchItems: (offset, limit) =>
                    Stream.value(page(offset, limit)),
                watchCount: () => Stream.value(100000),
                pageSize: 10,
              )
            : LazyListController<int>.future(
                getItems: (offset, limit) async => page(offset, limit),
                getCount: () async => 100000,
                pageSize: 10,
              );
        addTearDown(controller.dispose);
        var scrollController = ScrollController();
        addTearDown(scrollController.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: LazyListView<int>(
              controller: controller,
              scrollController: scrollController,
              itemExtent: 20,
              itemBuilder: (context, item, index) => Text('item $item'),
              itemLoadingBuilder: (context, index) => const SizedBox(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var height = tester.getSize(find.byType(LazyListView<int>)).height;
        for (var step = 0; step < 60; step++) {
          await tester.drag(find.byType(ListView), const Offset(0, -20));
          await tester.pump();
          await tester.idle();
          var first = scrollController.offset ~/ 20;
          var last = ((scrollController.offset + height) / 20).ceil() - 1;
          for (var index = first; index <= last; index++) {
            expect(
              controller.hasItem(index),
              isTrue,
              reason: 'step $step, row $index on screen',
            );
          }
          await tester.pumpAndSettle();
        }
        expect(scrollController.offset, greaterThan(1000));
        expect(
          loads.entries.where((entry) => entry.value > 1).map((e) => e.key),
          isEmpty,
        );
      },
    );
  }
}
