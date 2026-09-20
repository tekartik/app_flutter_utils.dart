---
name: tekartik-app-sdb-ui-flutter-list-view
description: >-
  Use when displaying the records of an sdb (package:idb_shim/sdb.dart) store
  or index query in a Flutter list with tekartik_app_sdb_ui_flutter:
  SdbStoreListView and SdbIndexListView lazily load pages of
  SdbRecordSnapshot/SdbIndexRecordSnapshot by offset/limit from a SdbStoreRef
  or SdbIndexRef with SdbFindOptions (boundaries, filter, descending,
  offset/limit window), one-shot or watched (watch: true, the list updates on
  store changes), with itemBuilder, itemLoadingBuilder, loadingBuilder,
  emptyBuilder, errorBuilder, pageSize, pageWindowMargin and itemExtent.
---

# tekartik_app_sdb_ui_flutter list views

`SdbStoreListView` and `SdbIndexListView` are `ListView`s that lazily load
the records of an sdb query page by page (offset/limit) and, when watched,
update themselves when the store changes. They are built on the generic
`LazyListView` of `tekartik_app_list_view_flutter`, re-exported by this
package.

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final notes = SdbStoreRef<int, SdbModel>('notes');

class NotesList extends StatelessWidget {
  final SdbDatabase db;
  const NotesList({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return SdbStoreListView<int, SdbModel>(
      client: db,
      store: notes,
      watch: true,
      itemExtent: 56,
      itemBuilder: (context, snapshot, index) =>
          ListTile(title: Text(snapshot.value['title'] as String)),
      emptyBuilder: (context) => const Center(child: Text('No note')),
    );
  }
}
```

## Guidelines

### Setup and imports

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_sdb_ui_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_sdb_ui
      version: '>=0.1.0'
  ```

* Import `package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart` for the
  widgets and controllers, and `package:idb_shim/sdb.dart` for the sdb types
  (`SdbStoreRef`, `SdbFindOptions`, `SdbBoundaries`, `SdbFilter`, ...). The
  package re-exports `tekartik_app_list_view_flutter` (`LazyListView`,
  `SliverLazyList`, `LazyListController` and the builder typedefs).
* Open the database as usual (`sdbFactorySqflite` on mobile/desktop,
  `sdbFactoryWeb` on the web, `newSdbFactoryMemory()` in tests) and pass the
  `SdbDatabase` down to the widgets; the widgets never open or close it.

### Choosing the widget

* `SdbStoreListView<K, V>` lists a store query in primary key order, items
  are `SdbRecordSnapshot<K, V>` (`key`, `value`, `ref`).
* `SdbIndexListView<K, V, I>` lists an index query in index key order, items
  are `SdbIndexRecordSnapshot<K, V, I>` (`key` is the primary key,
  `indexKey`, `value`, `store`, `index`). There is no `ref`: to write the
  record use `snapshot.store.record(snapshot.key)`.
* The type parameters must match the store/index reference: `K` is `int` or
  `String`, `V` is usually `SdbModel` (`Map<String, Object?>`), `I` is `int`,
  `String` or `SdbTimestamp`. `V` can also be a plain value type
  (`SdbStoreRef<int, String>`).
* Give either `client` + `store` (or `index`) and let the widget create and
  own its controller, or an external `controller` (see the
  `tekartik-app-sdb-ui-flutter-controller` skill), never both (assert).
* `client` is a `SdbClient`: pass the `SdbDatabase`. A `SdbTransaction` is
  accepted for one-shot lists but an IndexedDB transaction commits as soon as
  it is idle, so pages loaded later while scrolling fail; keep it for tests.

### Query

* `findOptions: SdbFindOptions<K>(boundaries:, filter:, descending:,
  offset:, limit:)`, typed by the index key `I` on `SdbIndexListView`.
  `boundaries` and `descending` are applied by the engine, `filter` runs in
  memory after them (for the count too): on big stores prefer an index with
  boundaries (`SdbBoundaries.values(lower, upper)`,
  `SdbBoundaries(index.lowerBoundary(v), null)`, `SdbBoundaries.key(v)`).
* `offset`/`limit` in `findOptions` do not paginate: they define a fixed
  window of the query result the list is restricted to (a "top 100" list for
  example). The count is clipped to the window and pages are computed
  relative to it. Pagination is `pageSize`.
* Keep the store/index references and `findOptions` stable across builds:
  declare the refs as top-level `final`s and build the options once (a
  field, `initState`, or a memoized value). The widget compares them with
  `==` in `didUpdateWidget` and recreates its controller (reload, loaded
  pages lost) whenever a new `SdbFindOptions` instance is given. Rebuild the
  options only when the query really changes (search text, sort order).

### One-shot or watched

* Default (`watch: false`): each page and the count are queried once
  (`findRecords`/`count`); the list does not reflect later writes. To reload,
  give the widget a new `key`, change the query, or call `refresh()` on an
  external controller.
* `watch: true`: pages are `onSnapshots` streams and the count is re-queried
  on every store change, so the list follows adds, updates and deletes (from
  any tab on the web). `client` must then be a `SdbDatabase`
  (`ArgumentError` otherwise).
* In watch mode every loaded page is a live query re-run on each write:
  keep `pageWindowMargin` (default 2 pages kept on each side of the built
  range, pages further away are dropped and their query cancelled). Never
  set it to `null` (keep everything) on a big store.

### Layout and states

* `itemBuilder(context, snapshot, index)` builds a loaded record.
  `itemLoadingBuilder(context, index)` builds the placeholder of a record
  whose page is loading (default: a 50 px `CircularProgressIndicator`); give
  it the same extent as a real item.
* `loadingBuilder` is shown until the first page arrives, `emptyBuilder` when
  the count is 0 (default: nothing), `errorBuilder(context, error,
  stackTrace)` on a query error (default: `Center(Text('Error: ...'))`).
  Provide `emptyBuilder` and `errorBuilder` in production screens.
* Set `itemExtent` (or `prototypeItem`, or `itemExtentBuilder`, only one of
  the three) on long lists: without a known extent a scrollbar drag or a
  `jumpTo` builds, and loads a page for, every item scrolled over.
* `pageSize` (default 50) is the `limit` of each query; a few screens of
  items per page is right. The usual `ListView` knobs are exposed:
  `padding`, `physics`, `shrinkWrap`, `reverse`, `scrollDirection`, `primary`
  and `scrollController` (a `ScrollController`, not the list controller).

## Examples

### Store list on a key range, newest first, with delete

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final events = SdbStoreRef<int, SdbModel>('events');

class RecentEvents extends StatefulWidget {
  final SdbDatabase db;
  const RecentEvents({super.key, required this.db});

  @override
  State<RecentEvents> createState() => _RecentEventsState();
}

class _RecentEventsState extends State<RecentEvents> {
  // Built once: a new instance on every build would recreate the controller.
  final findOptions = SdbFindOptions<int>(
    boundaries: SdbBoundaries.lowerValue(1000),
    descending: true,
  );

  @override
  Widget build(BuildContext context) {
    return SdbStoreListView<int, SdbModel>(
      client: widget.db,
      store: events,
      findOptions: findOptions,
      watch: true,
      pageSize: 40,
      itemExtent: 72,
      itemBuilder: (context, snapshot, index) => ListTile(
        title: Text(snapshot.value['title'] as String),
        subtitle: Text('#${snapshot.key}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          // The watched list updates itself after the delete.
          onPressed: () => snapshot.ref.delete(widget.db),
        ),
      ),
      itemLoadingBuilder: (context, index) =>
          const ListTile(title: Text('...')),
      emptyBuilder: (context) => const Center(child: Text('No event')),
      errorBuilder: (context, error, stackTrace) =>
          Center(child: Text('Error: $error')),
    );
  }
}
```

### Index list narrowed by a search prefix

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final contacts = SdbStoreRef<int, SdbModel>('contacts');
final contactsByName = contacts.index<String>('name');

class ContactSearch extends StatefulWidget {
  final SdbDatabase db;
  const ContactSearch({super.key, required this.db});

  @override
  State<ContactSearch> createState() => _ContactSearchState();
}

class _ContactSearchState extends State<ContactSearch> {
  SdbFindOptions<String>? _findOptions;

  void _onSearch(String text) {
    setState(() {
      // Rebuilt only when the query changes, the list reloads once.
      _findOptions = text.isEmpty
          ? null
          : SdbFindOptions<String>(
              boundaries: SdbBoundaries.values(text, '$text￿'),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(onChanged: _onSearch),
        Expanded(
          child: SdbIndexListView<int, SdbModel, String>(
            client: widget.db,
            index: contactsByName,
            findOptions: _findOptions,
            itemExtent: 56,
            itemBuilder: (context, snapshot, index) => ListTile(
              title: Text(snapshot.indexKey),
              // No ref on an index snapshot: go through the store.
              onTap: () => snapshot.store.record(snapshot.key).put(widget.db, {
                ...snapshot.value,
                'seen': true,
              }),
            ),
            emptyBuilder: (context) => const Center(child: Text('No match')),
          ),
        ),
      ],
    );
  }
}
```

### Fixed window: only the first 100 records

```dart
import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final scores = SdbStoreRef<int, SdbModel>('scores');
final scoresByValue = scores.index<int>('value');

// Top 100, highest first. The list count is at most 100 whatever the store
// holds; pages (pageSize) are relative to that window.
final top100 = SdbFindOptions<int>(descending: true, limit: 100);

Widget buildTop100(SdbDatabase db) => SdbIndexListView<int, SdbModel, int>(
  client: db,
  index: scoresByValue,
  findOptions: top100,
  itemExtent: 48,
  itemBuilder: (context, snapshot, index) => ListTile(
    leading: Text('${index + 1}'),
    title: Text(snapshot.value['player'] as String),
    trailing: Text('${snapshot.indexKey}'),
  ),
);
```

## Common mistakes

* Creating `SdbFindOptions` (or a store ref) inside `build`: the widget sees
  a new query on every rebuild and reloads from scratch.
* Using `findOptions.offset`/`limit` to paginate; they window the query,
  `pageSize` paginates.
* `watch: true` with a `SdbTransaction` as `client` (`ArgumentError`), or a
  transaction on any list that outlives it.
* Omitting `itemExtent` on a list of thousands of records.
* `pageWindowMargin: null` with `watch: true` on a big store: every page ever
  scrolled to stays a live query re-run on each write.
* Calling `dispose()` on a controller owned by the widget (it has none you
  can reach) or forgetting to dispose an external one.
* Expecting an index snapshot to have `ref`; use
  `snapshot.store.record(snapshot.key)`.
