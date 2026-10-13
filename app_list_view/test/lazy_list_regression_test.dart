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
}
