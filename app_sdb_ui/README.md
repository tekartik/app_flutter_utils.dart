# tekartik_app_sdb_ui_flutter

Flutter `ListView` widgets that lazily load the records of an sdb query (the
simple database API of [idb_shim](https://pub.dev/packages/idb_shim),
`package:idb_shim/sdb.dart`): a store (`SdbStoreListView`), an index
(`SdbIndexListView`) or a join of two stores (`SdbJoinListView`), one page at
a time, once or watched. Built on
[tekartik_app_list_view_flutter](../app_list_view).

## Getting started

Not on pub.dev, add it as a git dependency (with `idb_shim` and
`material_ui`, used in your code):

```yaml
dependencies:
  idb_shim: '>=2.11.3'
  material_ui: '>=1.5.0'
  tekartik_app_sdb_ui_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_sdb_ui
```

A list of notes that follows the writes (complete app in
[example/main.dart](example/main.dart)):

```dart
import 'package:idb_shim/sdb.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

final noteStore = SdbStoreRef<int, SdbModel>('note');

Widget notesList(SdbDatabase db) => SdbStoreListView<int, SdbModel>(
  client: db,
  store: noteStore,
  watch: true, // the list follows adds, updates and deletes
  itemExtent: 56,
  itemBuilder: (context, snapshot, index) =>
      ListTile(title: Text('${snapshot.value['text']}')),
  emptyBuilder: (context) => const Center(child: Text('No note')),
);
```

Platforms: every Flutter platform. The widgets never open the database: open
it with `sdbFactoryWeb` on the web, `sdbFactorySqflite` (package
`idb_sqflite`) on mobile and desktop, `sdbFactoryMemory` in tests.

The widgets are built with `package:material_ui` (the material library
published outside the Flutter SDK): use its `MaterialApp`, `Scaffold`... in
the app. Under a `package:flutter/material.dart` `MaterialApp` they fail
("No MaterialLocalizations found").

## Which widget

| Widget / controller | Lists | Items |
|---|---|---|
| `SdbStoreListView`, `SdbStoreListController` | a store, primary key order | `SdbRecordSnapshot<K, V>` |
| `SdbIndexListView`, `SdbIndexListController` | an index, index key order | `SdbIndexRecordSnapshot<K, V, I>` |
| `SdbJoinListView`, `SdbJoinListController` | each record of a source with the record(s) its join key matches | `SdbJoinRow<K, V, JK, JV>` |

- `findOptions` (`SdbFindOptions`): boundaries, filter, descending. An
  `offset`/`limit` there is a fixed window the list is restricted to (a "top
  100"), not the pagination: `pageSize` paginates.
- `watch: false` (default): each page and the count are read once.
  `watch: true`: they are re-read on every write (`client` must then be the
  `SdbDatabase`, not a transaction).
- Give `client` and the query and let the widget own its controller, or give
  a `controller` you create and dispose (for a `CustomScrollView`, below).

## Common pitfalls

- Mixing `package:flutter/material.dart` and `package:material_ui` widgets
  (see above).
- A filter change the widget cannot see: the arguments are compared by value
  (inline `SdbFindOptions` do not reload the list), but a filter only by its
  description, which does not show `anyInList`, the value type (`1` and `'1'`)
  nor the grouping of `and`/`or`. When only such a detail changes, give the
  widget a new `key`.
- Watched join lists follow the writes of this database connection only, not
  the ones of another browser tab (store and index lists follow both).
- Without `itemExtent` (or `prototypeItem`), a long jump in a long list
  builds, and loads a page for, every row it scrolls over.
- `pageWindowMargin: null` keeps every page scrolled through loaded, and
  watched: only for small lists.

## More examples

### Store list view

```dart
var store = SdbStoreRef<int, SdbModel>('item');

SdbStoreListView<int, SdbModel>(
  client: db,
  store: store,
  // watch: true, // to update the list on store changes (client must be a db)
  itemBuilder: (context, snapshot, index) =>
      ListTile(title: Text(snapshot.value.toString())),
);
```

### Index list view

```dart
var nameIndex = store.index<String>('name');

SdbIndexListView<int, SdbModel, String>(
  client: db,
  index: nameIndex,
  findOptions: SdbFindOptions(
    boundaries: SdbBoundaries(
      nameIndex.lowerBoundary('a'),
      nameIndex.upperBoundary('z'),
    ),
  ),
  itemBuilder: (context, snapshot, index) =>
      ListTile(title: Text(snapshot.indexKey)),
);
```

### Join list view

Shows the records of a source together with the records their join key
matches (see `joinIterate` in `idb_shim`), so a list showing both sides needs
one query per page instead of one extra read per row.

Both sides are explicit:

- `source` — what is iterated: `store.asJoinSourceAt('field')` (join key in a
  field), `store.asJoinSource` (join key is its primary key) or
  `index.asJoinSource` (join key is its index key, rows in index key order —
  the shape to prefer).
- `target` — what the join key is matched against: `store.asJoinTarget` (its
  primary key, at most one record) or `index.asJoinTarget` (its index key, any
  number of records, so a source record gives one row per match).

```dart
var authorStore = SdbStoreRef<int, SdbModel>('author');
var bookStore = SdbStoreRef<int, SdbModel>('book');
// A book value looks like {'title': 't1', 'authorId': 1}

SdbJoinListView<int, SdbModel, int, int, SdbModel>(
  client: db,
  source: bookStore.asJoinSourceAt('authorId'),
  target: authorStore.asJoinTarget,
  // joinOptions: SdbJoinFindOptions(inner: true), // skip books with no author
  // watch: true, // updates on changes of either store (client must be a db)
  itemBuilder: (context, row, index) => ListTile(
    title: Text('${row.record.value['title']}'),
    subtitle: Text('${row.joinedRecord?.value['name']}'),
  ),
);
```

Through the index on the join key — same rows, ordered by author, and the
implementation reads the join key straight from the index:

```dart
var bookAuthorIndex = bookStore.index<int>('authorId');

SdbJoinListView<int, SdbModel, int, int, SdbModel>(
  client: db,
  source: bookAuthorIndex.asJoinSource,
  target: authorStore.asJoinTarget,
  // findOptions applies to the index key.
  findOptions: SdbFindOptions(boundaries: SdbBoundaries.values(1, 10)),
  itemBuilder: (context, row, index) => ListTile(
    title: Text('${row.record.value['title']}'),
    subtitle: Text('${row.joinedRecord?.value['name']}'),
  ),
);
```

One to many, from the parent side: the target is an index, so a post with
three comments gives three rows.

```dart
var commentPostIndex = commentStore.index<int>('postId');

SdbJoinListView<int, SdbModel, int, int, SdbModel>(
  client: db,
  source: postStore.asJoinSource,
  target: commentPostIndex.asJoinTarget,
  itemBuilder: (context, row, index) => ListTile(
    title: Text('${row.record.value['title']}'),
    subtitle: Text('${row.joinedRecord?.value['text']}'),
  ),
);
```

### CustomScrollView / ListView.custom

Create a controller (dispose it yourself) and use the generic lazy list
widgets re-exported from `tekartik_app_list_view_flutter`:

```dart
final controller = SdbStoreListController<int, SdbModel>.watch(
  database: db,
  store: store,
);

CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('Items')),
    SliverLazyList<SdbRecordSnapshot<int, SdbModel>>(
      controller: controller,
      itemBuilder: (context, snapshot, index) =>
          ListTile(title: Text(snapshot.value.toString())),
    ),
  ],
);
```

