# tekartik_app_sdb_ui_flutter

ListView widgets that lazily load the records of an sdb (simple db from
`idb_shim`) query, defined by a `SdbStoreRef` or `SdbIndexRef` and
`SdbFindOptions`. Built on top of `tekartik_app_list_view_flutter`.

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
