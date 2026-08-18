import 'package:flutter/material.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_list_view_test_app_lib/lazy_list_view_page.dart';
import 'package:tekartik_list_view_test_app_lib/sliver_lazy_list_page.dart';

Future<void> _push(Widget page) async {
  await navigator.push<void>(MaterialPageRoute(builder: (context) => page));
}

/// List view test menu.
void defineMenu() {
  menu('list_view', () {
    item('LazyListView (future, 100000 items)', () async {
      await _push(const LazyListViewDemoPage(title: 'Future, 100000 items'));
    });
    item('LazyListView (future, no count)', () async {
      await _push(
        const LazyListViewDemoPage(
          title: 'Future, inferred total',
          itemCount: 1000,
          withCount: false,
        ),
      );
    });
    item('LazyListView (watch, 100000 items)', () async {
      await _push(
        const LazyListViewDemoPage(title: 'Watched, 100000 items', watch: true),
      );
    });
    item('LazyListView (watch, no page eviction)', () async {
      // Every page scrolled through stays watched and is re-queried on every
      // change: scroll far, start the background writer and watch the query
      // count explode (this is what pageWindowMargin prevents).
      await _push(
        const LazyListViewDemoPage(
          title: 'Watched, no eviction',
          watch: true,
          pageWindowMargin: null,
        ),
      );
    });
    item('LazyListView (watch, small pages)', () async {
      await _push(
        const LazyListViewDemoPage(
          title: 'Watched, page size 10',
          itemCount: 5000,
          watch: true,
          pageSize: 10,
          pageWindowMargin: 1,
        ),
      );
    });
    item('LazyListView (empty)', () async {
      await _push(
        Scaffold(
          appBar: AppBar(title: const Text('Empty')),
          body: LazyListView<String>(
            getItems: (offset, limit) async => <String>[],
            getCount: () async => 0,
            itemBuilder: (context, item, index) => Text(item),
            emptyBuilder: (context) => const Center(child: Text('No item')),
          ),
        ),
      );
    });
    item('LazyListView (error)', () async {
      await _push(
        Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: LazyListView<String>(
            getItems: (offset, limit) async => <String>[],
            getCount: () async => throw StateError('count failed'),
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      );
    });
    item('SliverLazyList (CustomScrollView)', () async {
      await _push(const SliverLazyListDemoPage());
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
