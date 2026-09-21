# tekartik_app_sdb_ui_flutter

ListView widgets that lazily load the records of an sdb (simple db from
`idb_shim`) query, defined by a `SdbStoreRef`, a `SdbIndexRef` or a join
(store or index on either side), and `SdbFindOptions`. Built on top of
`tekartik_app_list_view_flutter`.

- Records are loaded page by page (offset/limit), either one-shot (Future) or
  watched (Stream, the list updates when the store changes).
- The count query keeps the boundaries/filter of the find options.
- An offset/limit set in the find options defines a fixed window the list is
  restricted to (pages are computed relative to that window).

## Usage

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

## Setup

```yaml
dependencies:
  tekartik_app_sdb_ui_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_sdb_ui
    version: '>=0.1.0'
```
