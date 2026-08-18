import 'package:flutter/material.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';
import 'package:tekartik_list_view_test_app_lib/demo_store.dart';

/// Demo page for [LazyListView] on a [DemoStore].
///
/// The status bar at the bottom shows what the controller keeps in memory
/// (loaded items vs total) and how many page queries have been run: with a
/// watched list every loaded page is re-queried on every change, so the query
/// count is the direct measure of what [LazyListController.pageWindowMargin]
/// saves.
class LazyListViewDemoPage extends StatefulWidget {
  /// Page title.
  final String title;

  /// Item count of the demo store.
  final int itemCount;

  /// When true, pages and count are watched (Stream based), else one shot
  /// (Future based).
  final bool watch;

  /// When false, no count source is provided and the total is inferred from
  /// the last (short) page.
  final bool withCount;

  /// Page size.
  final int pageSize;

  /// See [LazyListController.pageWindowMargin], null keeps every page loaded
  /// (and watched) forever.
  final int? pageWindowMargin;

  /// Constructor
  const LazyListViewDemoPage({
    super.key,
    required this.title,
    this.itemCount = 100000,
    this.watch = false,
    this.withCount = true,
    this.pageSize = 50,
    this.pageWindowMargin = lazyListDefaultPageWindowMargin,
  });

  @override
  State<LazyListViewDemoPage> createState() => _LazyListViewDemoPageState();
}

class _LazyListViewDemoPageState extends State<LazyListViewDemoPage> {
  late final DemoStore _store;
  late final LazyListController<String> _controller;

  @override
  void initState() {
    super.initState();
    _store = DemoStore(count: widget.itemCount);
    _controller = widget.watch
        ? LazyListController<String>.stream(
            watchItems: _store.watchItems,
            watchCount: widget.withCount ? _store.watchCount : null,
            pageSize: widget.pageSize,
            pageWindowMargin: widget.pageWindowMargin,
          )
        : LazyListController<String>.future(
            getItems: _store.getItems,
            getCount: widget.withCount ? _store.getCount : null,
            pageSize: widget.pageSize,
            pageWindowMargin: widget.pageWindowMargin,
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    _store.dispose();
    super.dispose();
  }

  Widget _loadingTile(BuildContext context, int index) => ListTile(
    dense: true,
    leading: const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    title: Text('loading ${index + 1}...'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.watch) ...[
            IconButton(
              tooltip: 'Write one item',
              icon: const Icon(Icons.edit),
              onPressed: _store.writeOne,
            ),
            IconButton(
              tooltip: 'Remove last item',
              icon: const Icon(Icons.remove),
              onPressed: _store.removeLast,
            ),
            IconButton(
              tooltip: 'Background writer',
              icon: Icon(_store.isWriting ? Icons.pause : Icons.play_arrow),
              onPressed: () => setState(_store.toggleWriter),
            ),
          ],
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _store.resetQueryCount();
              _controller.refresh();
            },
          ),
        ],
      ),
      body: LazyListView<String>(
        controller: _controller,
        itemLoadingBuilder: _loadingTile,
        itemBuilder: (context, item, index) => ListTile(
          dense: true,
          leading: Text('${index + 1}'),
          title: Text(item),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Material(
          elevation: 3,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              var total = _controller.totalCount;
              return ListTile(
                dense: true,
                title: Text(
                  'loaded ${_controller.loadedItems.length} / '
                  '${total ?? '?'} items',
                ),
                subtitle: Text(
                  'page size ${widget.pageSize}, '
                  'window margin ${widget.pageWindowMargin ?? 'none'}, '
                  'page queries ${_store.queryCount}',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
