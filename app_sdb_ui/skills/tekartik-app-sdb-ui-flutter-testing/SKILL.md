---
name: tekartik-app-sdb-ui-flutter-testing
description: >-
  Use when writing tests for tekartik_app_sdb_ui_flutter list views and
  controllers (SdbStoreListView, SdbIndexListView, SdbStoreListController,
  SdbIndexListController) with an in-memory sdb database
  (newSdbFactoryMemory): waiting for isInitialized/hasItem in controller
  tests, and in testWidgets running database calls in tester.runAsync and
  pumping in small steps instead of pumpAndSettle.
---

# Testing sdb list views and controllers

Tests use an isolated in-memory sdb database (`newSdbFactoryMemory()` from
`package:idb_shim/sdb.dart`), opened in `setUp` and closed in `tearDown`.
Controllers are tested in plain `test`s by polling their state; widgets in
`testWidgets` with the database driven through `tester.runAsync`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final items = SdbStoreRef<int, SdbModel>('items');
final itemsByName = items.index<String>('name');

void main() {
  late SdbDatabase db;

  setUp(() async {
    db = await newSdbFactoryMemory().openDatabase(
      'test.db',
      options: SdbOpenDatabaseOptions(
        version: 1,
        schema: SdbDatabaseSchema(
          stores: [
            items.schema(
              autoIncrement: true,
              indexes: [itemsByName.schema(keyPath: 'name')],
            ),
          ],
        ),
      ),
    );
  });

  tearDown(() => db.close());

  test('count', () async {
    await items.add(db, {'name': 'a'});
    var controller = SdbStoreListController<int, SdbModel>(
      client: db,
      store: items,
    );
    addTearDown(controller.dispose);
    await waitUntil(() => controller.isInitialized);
    expect(controller.totalCount, 1);
  });
}

/// Poll a condition (real async), a following expect reports the failure.
Future<void> waitUntil(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
```

## Guidelines

### Database fixture

* `newSdbFactoryMemory()` per test (never the shared `sdbFactoryMemory`):
  tests stay independent and can run in parallel.
* Declare the store/index refs as top-level `final`s, open with a
  `SdbDatabaseSchema` (or `onVersionChange` with `e.db.createStore(store)`
  and `openStore.createIndex(index, 'field')`). Close in `tearDown`.
* Seed data with `store.add(db, value)` (auto-increment keys) or
  `store.record(key).put(db, value)` (chosen keys) before creating the
  controller or pumping the widget, unless the test is about live updates.

### Controller tests (no widget)

* Create the controller, `await waitUntil(() => controller.isInitialized)`,
  then check `totalCount`.
* `controller.getItem(i)` starts loading the page of `i` and returns `null`
  on the first call: request the indexes, `await waitUntil(() =>
  controller.hasItem(i))`, then read `controller.getItem(i)?.value` (or
  `.indexKey` on an index controller).
* Read through `controller.loadedItems[i]` when the test is about page
  eviction: `getItem` marks the index as requested and would keep its page in
  the window. Use `pageWindowMargin: 0` and a small `pageSize` to test
  eviction, then `expect(controller.hasItem(0), isFalse)` after scrolling to
  a far index.
* Watched controllers (`.watch(database: db, ...)`): write to the store,
  then `waitUntil(() => controller.totalCount == n)` or `waitUntil(() =>
  controller.getItem(0)?.value == updated)`; the count and pages update
  asynchronously.
* Always dispose the controller (`addTearDown(controller.dispose)` right
  after creating it) or the watch subscriptions outlive the test.
* Use a small `pageSize` (2 or 3) so a few records exercise several pages,
  and a `findOptions` window (`SdbFindOptions(offset: 2, limit: 5)`) to test
  the clipped count and relative indexes.

### Widget tests

* The in-memory database completes its work on the real event loop, which
  the fake async of `testWidgets` does not drive: run every database call in
  `await tester.runAsync(() => ...)`, seeding before `pumpWidget` and writes
  during the test alike.
* Do not use `pumpAndSettle`: the default loading placeholders are
  `CircularProgressIndicator`s that never settle and the database does not
  progress on the fake clock. Pump in small steps interleaved with a
  `tester.runAsync` delay until the expected widget is found
  (`pumpUntilFound` below), then `expect`.
* Wrap the list in `MaterialApp(home: Scaffold(body: ...))` and give the
  items a fixed height (`SizedBox(height: 50, child: Text(...))`, also in
  `itemLoadingBuilder`) so a known number of rows fits the test viewport;
  only built rows can be found.
* Put `timeout: const Timeout(Duration(seconds: 10))` on each `testWidgets`
  so a list that never loads fails fast.
* For a watched list (`watch: true`), write through `tester.runAsync` after
  the first render and `pumpUntilFound` the new text.

## Examples

### Widget test helpers and a watched list

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final simple = SdbStoreRef<int, String>('simple');

/// Pump until [finder] matches, letting the database work run.
/// A following expect reports the failure if it never does.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
}

void main() {
  late SdbDatabase db;

  setUp(() async {
    db = await newSdbFactoryMemory().openDatabase(
      'test.db',
      options: SdbOpenDatabaseOptions(
        version: 1,
        schema: SdbDatabaseSchema(stores: [simple.schema()]),
      ),
    );
  });
  tearDown(() => db.close());

  testWidgets('watched store list updates', (tester) async {
    await tester.runAsync(() => simple.record(0).put(db, 'first'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SdbStoreListView<int, String>(
            client: db,
            store: simple,
            watch: true,
            pageSize: 2,
            itemBuilder: (context, snapshot, index) =>
                SizedBox(height: 50, child: Text(snapshot.value)),
            itemLoadingBuilder: (context, index) =>
                const SizedBox(height: 50, child: Text('loading...')),
            emptyBuilder: (context) => const Text('empty'),
          ),
        ),
      ),
    );

    await pumpUntilFound(tester, find.text('first'));
    expect(find.text('first'), findsOneWidget);

    await tester.runAsync(() => simple.record(1).put(db, 'second'));
    await pumpUntilFound(tester, find.text('second'));
    expect(find.text('second'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 10)));
}
```

### Index controller order and boundaries

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final items = SdbStoreRef<int, SdbModel>('items');
final itemsByName = items.index<String>('name');

Future<void> waitUntil(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late SdbDatabase db;

  setUp(() async {
    db = await newSdbFactoryMemory().openDatabase(
      'test.db',
      options: SdbOpenDatabaseOptions(
        version: 1,
        schema: SdbDatabaseSchema(
          stores: [
            items.schema(
              autoIncrement: true,
              indexes: [itemsByName.schema(keyPath: 'name')],
            ),
          ],
        ),
      ),
    );
    await items.add(db, {'name': 'cherry'});
    await items.add(db, {'name': 'apple'});
    await items.add(db, {'name': 'banana'});
  });
  tearDown(() => db.close());

  test('sorted by index key from banana', () async {
    var controller = SdbIndexListController<int, SdbModel, String>(
      client: db,
      index: itemsByName,
      findOptions: SdbFindOptions<String>(
        boundaries: SdbBoundaries(itemsByName.lowerBoundary('banana'), null),
      ),
      pageSize: 2,
    );
    addTearDown(controller.dispose);

    await waitUntil(() => controller.isInitialized);
    expect(controller.totalCount, 2);

    controller.getItem(0);
    await waitUntil(() => controller.hasItem(0) && controller.hasItem(1));
    expect(controller.getItem(0)?.indexKey, 'banana');
    expect(controller.getItem(1)?.indexKey, 'cherry');
  });
}
```

## Common mistakes

* `await tester.pumpAndSettle()` on a lazy list: times out on the progress
  indicator placeholders.
* Seeding or writing the database outside `tester.runAsync` in a widget test:
  the write never completes and the list stays on its loading state.
* `expect(controller.getItem(0)?.value, ...)` right after creating the
  controller: the first `getItem` only starts the load, wait for
  `hasItem(0)`.
* Reusing the shared `sdbFactoryMemory` across tests: data leaks from one
  test to the next.
* Not disposing a watched controller: store listeners keep running after
  the database is closed.
