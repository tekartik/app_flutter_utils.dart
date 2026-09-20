---
name: tekartik-app-sdb-ui-flutter-controller
description: >-
  Use when an sdb (package:idb_shim/sdb.dart) query must feed a custom lazy
  list layout in Flutter with tekartik_app_sdb_ui_flutter: SdbStoreListController
  and SdbIndexListController (one-shot or .watch) used with SliverLazyList in a
  CustomScrollView, LazyListViewDelegate with ListView.custom, an external
  controller shared with SdbStoreListView, refresh(), getItem/hasItem/
  totalCount/loadedItems, pageWindowMargin eviction, and the
  sdbPageFindOptions/sdbCountFindOptions/sdbWindowCount helpers to build a
  custom LazyListController (typed models, transactions).
---

# tekartik_app_sdb_ui_flutter controllers

`SdbStoreListController<K, V>` and `SdbIndexListController<K, V, I>` are
`LazyListController`s (from `tekartik_app_list_view_flutter`, re-exported)
that page an sdb store or index query. `SdbStoreListView`/`SdbIndexListView`
create one internally; create it yourself for slivers, `ListView.custom`,
pull-to-refresh, or to read the state (count, error) elsewhere.

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final items = SdbStoreRef<int, SdbModel>('items');

class ItemsScreen extends StatefulWidget {
  final SdbDatabase db;
  const ItemsScreen({super.key, required this.db});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late final controller = SdbStoreListController<int, SdbModel>.watch(
    database: widget.db,
    store: items,
  );

  @override
  void dispose() {
    controller.dispose(); // never disposed by the widgets using it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Items')),
        SliverLazyList<SdbRecordSnapshot<int, SdbModel>>(
          controller: controller,
          itemExtent: 56,
          itemBuilder: (context, snapshot, index) =>
              ListTile(title: Text(snapshot.value['name'] as String)),
        ),
      ],
    );
  }
}
```

## Guidelines

### Creating a controller

* One-shot (`Future` based): `SdbStoreListController<K, V>(client:, store:,
  findOptions:, pageSize:, pageWindowMargin:)` and
  `SdbIndexListController<K, V, I>(client:, index:, ...)`. Each page is one
  `findRecords` and the count one `count`; later writes are not reflected
  until `refresh()`.
* Watched (`Stream` based): `SdbStoreListController<K, V>.watch(database:,
  store:, ...)` and `SdbIndexListController<K, V, I>.watch(database:, index:,
  ...)`. Pages are `onSnapshots` streams and the count is re-queried on every
  store change (through `addOnChangesListener`). Needs a `SdbDatabase`, not
  a transaction.
* Create it once (`initState`, a `late final` field, a riverpod/provider
  holder), pass it to the widgets and call `dispose()` when done. The
  widgets (`SdbStoreListView`, `LazyListView`, `SliverLazyList`) only listen
  to an external controller, they never dispose it.
* `findOptions` works as in the widgets: `boundaries`, `filter`, `descending`
  and an optional `offset`/`limit` window the list is restricted to; the
  count is clipped to the window. To change the query, create a new
  controller (and dispose the old one), the options are fixed at creation.

### Using it in a layout

* `SdbStoreListView(controller: c, itemBuilder: ...)` /
  `SdbIndexListView(controller: c, ...)`: same widgets as with `client` +
  `store`, with the loading/empty/error states handled. Do not pass
  `client`/`store`/`findOptions`/`watch` along with `controller` (assert).
* `SliverLazyList<T>(controller:, itemBuilder:, itemLoadingBuilder:,
  itemExtent: | prototypeItem: | itemExtentBuilder:)` inside a
  `CustomScrollView`, `T` being `SdbRecordSnapshot<K, V>` or
  `SdbIndexRecordSnapshot<K, V, I>`. It rebuilds itself on controller
  changes but has no empty, loading or error state: derive them from the
  controller with a `ListenableBuilder` and swap slivers (see the example).
  Until the count is known it builds loading placeholders.
* `LazyListViewDelegate<T>(controller:, itemBuilder:, itemLoadingBuilder:)`
  is a `SliverChildBuilderDelegate` for `ListView.custom(childrenDelegate:)`
  or `SliverList(delegate:)`. It captures `controller.revision` when
  created, so create it inside a `ListenableBuilder(listenable: controller)`
  (or an `AnimatedBuilder`) to get rebuilt on changes.
* Give the items a known extent on long lists (`itemExtent`,
  `prototypeItem` or `itemExtentBuilder`, only one): a scrollbar drag on a
  list of unknown extent builds and loads every item scrolled over.

### Reading the state

* `getItem(index)` returns the item or `null` while its page loads (or past
  the end); it triggers the page load and marks the index as needed for the
  page window. This is what the delegates call from `build`.
* `hasItem(index)` tells a loading item from a `null` value.
  `loadedItems` is the `Map<int, T>` of the loaded items (read only, does
  not trigger anything). `totalCount` is `null` until the count is known,
  `isInitialized` turns true once the count (or its first error) arrived,
  `hasEverLoadedItems` distinguishes an initial load from an all-pages
  evicted state, `error`/`stackTrace` hold the last failure.
* `refresh()` clears everything (items, count, error, subscriptions) and
  reloads: use it for pull-to-refresh on a one-shot controller, or after a
  bulk import when not watching. A watched controller does not need it.
* It is a `ChangeNotifier`: `addListener`/`ListenableBuilder`. Notifications
  are coalesced once per microtask (a single write re-emits every watched
  page). `revision` increments on every change.
* `pageWindowMargin` (default `lazyListDefaultPageWindowMargin`, 2): pages
  further than that many pages from the range built since the last frame are
  evicted, their items dropped and, when watching, their query cancelled.
  This bounds memory and the number of live queries. `null` keeps every page
  (small lists only), `0` keeps only the built pages.

### Building your own controller with the helpers

For a query the two controllers do not cover (mapping snapshots to typed
models at load time, several stores, a custom `SdbClient`), write a
`LazyListController<T>` with `getItems`/`getCount` (or
`watchItems`/`watchCount`) and reuse the window arithmetic:

* `sdbPageFindOptions(base, offset, limit)` composes the base
  `SdbFindOptions` with a page: it returns the options to query, or `null`
  when the page is outside the base `offset`/`limit` window (return an empty
  list, no query needed).
* `sdbCountFindOptions(base)` keeps `boundaries` and `filter` only, for
  `count`.
* `sdbWindowCount(base, rawCount)` clips a raw count to the window.

## Examples

### CustomScrollView with empty and error states

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final books = SdbStoreRef<int, SdbModel>('books');
final booksByTitle = books.index<String>('title');

typedef BookSnapshot = SdbIndexRecordSnapshot<int, SdbModel, String>;

class BooksScreen extends StatefulWidget {
  final SdbDatabase db;
  const BooksScreen({super.key, required this.db});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late final controller = SdbIndexListController<int, SdbModel, String>.watch(
    database: widget.db,
    index: booksByTitle,
    pageSize: 30,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        Widget body;
        var error = controller.error;
        if (error != null) {
          body = SliverFillRemaining(child: Center(child: Text('$error')));
        } else if (controller.totalCount == 0) {
          body = const SliverFillRemaining(
            child: Center(child: Text('No book')),
          );
        } else {
          body = SliverLazyList<BookSnapshot>(
            controller: controller,
            itemExtent: 56,
            itemBuilder: (context, snapshot, index) =>
                ListTile(title: Text(snapshot.indexKey)),
            itemLoadingBuilder: (context, index) =>
                const ListTile(title: Text('...')),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Books (${controller.totalCount ?? '...'})'),
            ),
            body,
          ],
        );
      },
    );
  }
}
```

### Pull to refresh on a one-shot list

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final logs = SdbStoreRef<int, SdbModel>('logs');

class LogsView extends StatefulWidget {
  final SdbDatabase db;
  const LogsView({super.key, required this.db});

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  late final controller = SdbStoreListController<int, SdbModel>(
    client: widget.db,
    store: logs,
    findOptions: SdbFindOptions<int>(descending: true),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: SdbStoreListView<int, SdbModel>(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemExtent: 48,
        itemBuilder: (context, snapshot, index) =>
            ListTile(title: Text(snapshot.value['message'] as String)),
      ),
    );
  }
}
```

### Typed model controller with the pagination helpers

```dart
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final notes = SdbStoreRef<int, SdbModel>('notes');

class Note {
  final int id;
  final String title;
  Note.fromSnapshot(SdbRecordSnapshot<int, SdbModel> snapshot)
    : id = snapshot.key,
      title = snapshot.value['title'] as String;
}

/// A `LazyListController<Note>` on the notes store, honoring an optional
/// window/boundaries in [base].
LazyListController<Note> noteListController(
  SdbDatabase db, {
  SdbFindOptions<int>? base,
}) {
  return LazyListController<Note>.future(
    getItems: (offset, limit) async {
      var options = sdbPageFindOptions(base, offset, limit);
      if (options == null) {
        return <Note>[]; // page outside the window
      }
      var snapshots = await notes.findRecords(db, options: options);
      return snapshots.map(Note.fromSnapshot).toList();
    },
    getCount: () async => sdbWindowCount(
      base,
      await notes.count(db, options: sdbCountFindOptions(base)),
    ),
    pageSize: 25,
  );
}
```

## Common mistakes

* Creating the controller in `build`: a new query on every rebuild, and a
  leak since nobody disposes the previous one.
* Forgetting `controller.dispose()` in `State.dispose` (watched controllers
  keep store listeners and page streams alive).
* Passing `controller` together with `client`/`store` to a list view.
* Using `LazyListViewDelegate` outside a `ListenableBuilder` on the
  controller: the list never updates.
* Expecting `SliverLazyList` to render an empty or error state.
* Calling `refresh()` in a watched controller's change handler (it already
  updates; refreshing loops on the re-query).
