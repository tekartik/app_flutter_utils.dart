---
name: tekartik-app-list-view-flutter-lazy-list
description: >-
  Use when displaying a long or paginated list in Flutter whose items are
  fetched by offset/limit (database, REST page endpoint) with
  tekartik_app_list_view_flutter: LazyListView, SliverLazyList,
  LazyListViewDelegate and LazyListController (LazyListController.future,
  LazyListController.stream, getItems/watchItems, getCount/watchCount,
  pageSize, pageWindowMargin, refresh, getItem, hasItem, totalCount,
  loadedItems, hasEverLoadedItems, revision), the LazyItemsGetter,
  LazyItemsStreamer, LazyCountGetter, LazyCountStreamer,
  LazyItemWidgetBuilder, LazyItemLoadingWidgetBuilder and
  LazyErrorWidgetBuilder typedefs, and the
  package:tekartik_app_list_view_flutter/list_view_flutter.dart import.
---

# Lazy list views (tekartik_app_list_view_flutter)

`tekartik_app_list_view_flutter` displays a list whose items are loaded page
by page (offset/limit) instead of all at once, from a `Future` source or from
a `Stream` source that keeps the visible pages live. A single
`LazyListController<T>` holds the paging state, and three widgets render it:
`LazyListView` (a plain `ListView`), `SliverLazyList` (inside a
`CustomScrollView`) and `LazyListViewDelegate` (for `ListView.custom` /
`SliverList`).

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_list_view_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_list_view
      version: '>=0.1.0'
  ```

* One import for everything:
  `package:tekartik_app_list_view_flutter/list_view_flutter.dart`. It exports
  `LazyListView`, `SliverLazyList`, `LazyListViewDelegate`,
  `LazyListController`, `lazyListDefaultPageWindowMargin` and the
  `LazyItemsGetter` / `LazyItemsStreamer` / `LazyCountGetter` /
  `LazyCountStreamer` / `LazyItemWidgetBuilder` /
  `LazyItemLoadingWidgetBuilder` / `LazyErrorWidgetBuilder` typedefs.
* Data sources, exactly one item source and at most one count source
  (asserted in the constructor):
  * `getItems: (offset, limit) async => ...` returns `Future<List<T>>`, a
    one-shot fetch per page.
  * `watchItems: (offset, limit) => ...` returns `Stream<List<T>>`, the page
    stays watched and the list updates on every emission.
  * `getCount: () async => ...` / `watchCount: () => ...` give the total.
    They are optional: with no count source the end of the list is inferred
    when a page returns fewer items than `pageSize`.
  * Future and Stream sources can be mixed (e.g. `watchItems` +
    `getCount`) with the default `LazyListController` constructor;
    `LazyListController.future()` and `LazyListController.stream()` are the
    typed shortcuts.
* `LazyListView` takes either an external `controller` or the fetch callbacks
  (asserted, never both). With the callbacks it creates and disposes its own
  controller; an external controller is never disposed by the widget, the
  owner must `dispose()` it (`SliverLazyList` and `LazyListViewDelegate`
  always need an external one).
* Pass the callbacks as stable references (a method or a field, not a closure
  rebuilt every `build`) when you let `LazyListView` own its controller:
  `didUpdateWidget` recreates the controller whenever `getItems`,
  `watchItems`, `getCount`, `watchCount`, `pageSize` or `pageWindowMargin`
  change, so a fresh closure on each build reloads everything.
* On a long list give the items a known extent: `itemExtent` (fixed),
  `prototypeItem` (measured from a sample widget) or `itemExtentBuilder` (per
  index). Only one of the three. Without it a fling or a `jumpTo` builds
  every item scrolled over, and each one triggers a page load.
* `pageSize` defaults to 50. `pageWindowMargin` (default
  `lazyListDefaultPageWindowMargin`, 2) is the number of pages kept loaded on
  each side of the range currently requested; pages outside it are dropped
  and, in stream mode, their subscription is cancelled. Use `null` only for
  small lists: in stream mode it keeps one live query per visited page alive
  forever.
* Builders on `LazyListView`: `itemBuilder(context, item, index)` (required),
  `itemLoadingBuilder(context, index)` for a not-yet-loaded item (default: a
  50px `CircularProgressIndicator`), `loadingBuilder(context)` shown until
  the first data arrives, `emptyBuilder(context)` when `totalCount == 0`, and
  `errorBuilder(context, error, stackTrace)`. `SliverLazyList` and
  `LazyListViewDelegate` only take `itemBuilder` and `itemLoadingBuilder`:
  handle the global loading/empty/error states yourself around the sliver if
  needed.
* Controller API when driving it directly: `getItem(index)` returns the item
  or `null` and triggers the load of its page (use `hasItem(index)` when `T`
  is nullable), `loadedItems` is the currently cached `Map<int, T>`,
  `totalCount` the known or inferred total (`null` while unknown),
  `isInitialized`, `hasEverLoadedItems`, `error`/`stackTrace`, `revision`
  (bumped on every change, used by `LazyListViewDelegate.shouldRebuild`).
  `refresh()` cancels everything, clears the cache and reloads.
* `LazyListController` is a `ChangeNotifier` and notifies at most once per
  microtask. `LazyListView` and `SliverLazyList` listen on their own; with
  `LazyListViewDelegate` you must rebuild yourself, e.g. wrap the
  `ListView.custom` in a `ListenableBuilder(listenable: controller, ...)`, or
  the delegate is never re-created and the list never updates.
* The list is a pure view: it never opens, closes or writes the underlying
  data source. After a write that changes the data, call `refresh()` (Future
  mode) or let the streams emit (Stream mode).
* Testing: the controller has no Flutter dependency beyond `ChangeNotifier`,
  so its paging logic can be tested with plain `test()` and an in-memory
  list, awaiting a `Future<void>.delayed(Duration.zero)` between
  `getItem(...)` calls (see `test/lazy_list_view_test.dart`).

## Examples

### Future based list with a count

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

class Note {
  final String title;
  Note(this.title);
}

Future<List<Note>> fetchNotes(int offset, int limit) async =>
    List.generate(limit, (i) => Note('note ${offset + i}'));

Future<int> fetchNoteCount() async => 10000;

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: LazyListView<Note>(
        getItems: fetchNotes,
        getCount: fetchNoteCount,
        pageSize: 50,
        itemExtent: 56,
        itemBuilder: (context, note, index) =>
            ListTile(title: Text(note.title), trailing: Text('$index')),
        itemLoadingBuilder: (context, index) =>
            const ListTile(title: Text('...')),
        loadingBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        emptyBuilder: (context) => const Center(child: Text('No note')),
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Text('Failed: $error')),
      ),
    );
  }
}
```

### Stream based list, live updates, no count source

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

/// Watches a page of a reactive store, re-emits on every change.
Stream<List<String>> watchRows(int offset, int limit) async* {
  yield List.generate(limit, (i) => 'row ${offset + i}');
}

class RowsView extends StatefulWidget {
  const RowsView({super.key});

  @override
  State<RowsView> createState() => _RowsViewState();
}

class _RowsViewState extends State<RowsView> {
  // Stable reference: a closure rebuilt in build() would reload everything.
  late final _watchRows = watchRows;

  @override
  Widget build(BuildContext context) {
    // No count source: the end is inferred when a page is not full.
    return LazyListView<String>(
      watchItems: _watchRows,
      pageSize: 20,
      prototypeItem: const ListTile(title: Text('row')),
      itemBuilder: (context, row, index) => ListTile(title: Text(row)),
    );
  }
}
```

### Shared controller in a CustomScrollView

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

Future<List<String>> fetchItems(int offset, int limit) async =>
    List.generate(limit, (i) => 'item ${offset + i}');

Future<int> fetchCount() async => 500;

class ItemsScrollView extends StatefulWidget {
  const ItemsScrollView({super.key});

  @override
  State<ItemsScrollView> createState() => _ItemsScrollViewState();
}

class _ItemsScrollViewState extends State<ItemsScrollView> {
  late final LazyListController<String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LazyListController<String>.future(
      getItems: fetchItems,
      getCount: fetchCount,
      pageSize: 50,
    );
  }

  @override
  void dispose() {
    // The widget never disposes an external controller.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Items'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _controller.refresh,
            ),
          ],
        ),
        SliverLazyList<String>(
          controller: _controller,
          itemExtent: 56,
          itemBuilder: (context, item, index) => ListTile(title: Text(item)),
          itemLoadingBuilder: (context, index) => const SizedBox(height: 56),
        ),
      ],
    );
  }
}
```

### ListView.custom with the delegate (rebuild it yourself)

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

class CustomLazyList extends StatelessWidget {
  final LazyListController<String> controller;

  const CustomLazyList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // The delegate captures controller.revision when it is built: without a
    // ListenableBuilder nothing would rebuild it and the list would stay
    // empty.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListView.custom(
        itemExtent: 56,
        childrenDelegate: LazyListViewDelegate<String>(
          controller: controller,
          itemBuilder: (context, item, index) => ListTile(title: Text(item)),
          itemLoadingBuilder: (context, index) => const SizedBox(height: 56),
        ),
      ),
    );
  }
}
```

### Unit testing the controller

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

Future<void> pumpAsync() => Future<void>.delayed(Duration.zero);

void main() {
  test('lazy loading by page', () async {
    var data = List.generate(10, (i) => 'item $i');
    var controller = LazyListController<String>.future(
      getItems: (offset, limit) async => data.skip(offset).take(limit).toList(),
      getCount: () async => data.length,
      pageSize: 3,
    );
    await pumpAsync();
    expect(controller.totalCount, 10);

    expect(controller.getItem(0), isNull); // page 0 load started
    await pumpAsync();
    expect(controller.getItem(0), 'item 0');
    expect(controller.hasItem(2), isTrue);
    expect(controller.getItem(10), isNull); // past the end

    controller.dispose();
  });
}
```
