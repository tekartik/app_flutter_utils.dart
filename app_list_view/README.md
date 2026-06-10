# tekartik_app_list_view_flutter

ListView for Flutter with lazy loading of items by offset/limit and count,
Future or Stream based, with `CustomScrollView`/`ListView.custom` support.

## Design

A single controller class `LazyListController<T>` handles both Future and
Stream sources (the paging/cache logic is the same, only the transport
differs), with `LazyListController.future()` and `LazyListController.stream()`
named constructors. The default constructor allows mixing sources (e.g. Future
based items with a Stream based count).

- Items are fetched page by page using offset and limit.
- The count is optional: when missing, the end of the list is inferred when a
  page returns fewer items than requested.
- Stream based pages remain watched, so item updates are reflected live.
- `LazyListView` shows a global `loadingBuilder` until the first data is
  available, then `itemLoadingBuilder` as a placeholder for each item being
  loaded (plus `errorBuilder` and `emptyBuilder`).

Three UI entry points share the same controller:

- `LazyListView<T>`: a plain `ListView`.
- `SliverLazyList<T>`: a sliver to use inside a `CustomScrollView`.
- `LazyListViewDelegate<T>`: a `SliverChildBuilderDelegate` to use with
  `ListView.custom` or `SliverList` directly.

## Usage

### Simple list view (Future based)

```dart
LazyListView<String>(
  getItems: (offset, limit) => fetchItems(offset, limit),
  getCount: () => fetchCount(),
  pageSize: 50,
  itemBuilder: (context, item, index) => ListTile(title: Text(item)),
);
```

### Stream based (reactive database)

```dart
LazyListView<Record>(
  watchItems: (offset, limit) => store.onRecords(offset: offset, limit: limit),
  watchCount: () => store.onCount(),
  itemBuilder: (context, record, index) => RecordTile(record),
);
```

### CustomScrollView

Create a controller (keep it in your state and dispose it) and use the sliver:

```dart
final lazyController = LazyListController<String>.future(
  getItems: (offset, limit) => fetchItems(offset, limit),
  getCount: () => fetchCount(),
);

CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('Items')),
    SliverLazyList<String>(
      controller: lazyController,
      itemBuilder: (context, item, index) => ListTile(title: Text(item)),
    ),
  ],
);
```

### ListView.custom

```dart
ListView.custom(
  childrenDelegate: LazyListViewDelegate<String>(
    controller: lazyController,
    itemBuilder: (context, item, index) => ListTile(title: Text(item)),
  ),
);
```

## Setup

```yaml
dependencies:
  tekartik_app_list_view_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_list_view
    version: '>=0.1.0'
```
