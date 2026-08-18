import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';
import 'package:tekartik_sdb_ui_test_app_lib/demo_db.dart';

/// What the demo page lists.
enum SdbListSource {
  /// The note store, by key.
  store,

  /// The note name index, by name.
  nameIndex,
}

/// Demo page for [SdbStoreListView] and [SdbIndexListView].
///
/// The status bar shows what the controller keeps loaded: with [watch] on,
/// each loaded page keeps a live query re-run on every change, so only the
/// pages around the visible range are kept (see
/// [LazyListController.pageWindowMargin]). Start the background writer and
/// scroll to see the list stay responsive.
class SdbListViewDemoPage extends StatefulWidget {
  /// Page title.
  final String title;

  /// Store or index.
  final SdbListSource source;

  /// When true the query is watched and the list updates on changes.
  final bool watch;

  /// When true, only the notes of the first category are listed (custom
  /// filter, i.e. a full scan on each query).
  final bool filtered;

  /// Page size.
  final int pageSize;

  /// See [LazyListController.pageWindowMargin], null keeps every page loaded
  /// (and watched) forever.
  final int? pageWindowMargin;

  /// Constructor
  const SdbListViewDemoPage({
    super.key,
    required this.title,
    this.source = SdbListSource.store,
    this.watch = false,
    this.filtered = false,
    this.pageSize = 50,
    this.pageWindowMargin = lazyListDefaultPageWindowMargin,
  });

  @override
  State<SdbListViewDemoPage> createState() => _SdbListViewDemoPageState();
}

class _SdbListViewDemoPageState extends State<SdbListViewDemoPage> {
  final _demoDb = DemoDb.instance;
  SdbStoreListController<int, SdbModel>? _storeController;
  SdbIndexListController<int, SdbModel, String>? _indexController;

  LazyListController<Object?>? get _controller =>
      _storeController ?? _indexController;

  @override
  void initState() {
    super.initState();
    unawaited(_initController());
  }

  /// Open the database and create the controller once, never in build.
  Future<void> _initController() async {
    var db = await _demoDb.openDatabase();
    if (!mounted) {
      return;
    }
    setState(() {
      switch (widget.source) {
        case SdbListSource.store:
          _storeController = widget.watch
              ? SdbStoreListController<int, SdbModel>.watch(
                  database: db,
                  store: noteStore,
                  findOptions: _findOptions(),
                  pageSize: widget.pageSize,
                  pageWindowMargin: widget.pageWindowMargin,
                )
              : SdbStoreListController<int, SdbModel>(
                  client: db,
                  store: noteStore,
                  findOptions: _findOptions(),
                  pageSize: widget.pageSize,
                  pageWindowMargin: widget.pageWindowMargin,
                );
        case SdbListSource.nameIndex:
          _indexController = widget.watch
              ? SdbIndexListController<int, SdbModel, String>.watch(
                  database: db,
                  index: noteNameIndex,
                  findOptions: _findOptions(),
                  pageSize: widget.pageSize,
                  pageWindowMargin: widget.pageWindowMargin,
                )
              : SdbIndexListController<int, SdbModel, String>(
                  client: db,
                  index: noteNameIndex,
                  findOptions: _findOptions(),
                  pageSize: widget.pageSize,
                  pageWindowMargin: widget.pageWindowMargin,
                );
      }
    });
  }

  @override
  void dispose() {
    _demoDb.stopWriter();
    _controller?.dispose();
    super.dispose();
  }

  /// Only list the notes of the first category, using a custom filter.
  SdbFindOptions<K>? _findOptions<K extends SdbKey>() => widget.filtered
      ? SdbFindOptions<K>(
          filter: SdbFilter.custom(
            (snapshot) => snapshot['category'] == demoCategories.first,
          ),
        )
      : null;

  Widget _loadingTile(BuildContext context, int index) => ListTile(
    dense: true,
    leading: const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    title: Text('loading ${index + 1}...'),
  );

  Widget _tile(int index, String name, Object? value) => ListTile(
    dense: true,
    leading: Text('${index + 1}'),
    title: Text(name),
    subtitle: Text('$value'),
  );

  Widget _emptyView(BuildContext context) =>
      const Center(child: Text('No note, populate the database first'));

  Widget _buildList() {
    var storeController = _storeController;
    if (storeController != null) {
      return SdbStoreListView<int, SdbModel>(
        controller: storeController,
        itemLoadingBuilder: _loadingTile,
        emptyBuilder: _emptyView,
        itemBuilder: (context, snapshot, index) => _tile(
          index,
          snapshot.value['name'] as String? ?? '',
          snapshot.value['value'],
        ),
      );
    }
    var indexController = _indexController;
    if (indexController != null) {
      return SdbIndexListView<int, SdbModel, String>(
        controller: indexController,
        itemLoadingBuilder: _loadingTile,
        emptyBuilder: _emptyView,
        itemBuilder: (context, snapshot, index) =>
            _tile(index, snapshot.indexKey, snapshot.value['value']),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStatus() {
    var controller = _controller;
    var subtitle = Text(
      '${widget.watch ? 'watched' : 'one shot'}'
      '${widget.filtered ? ', filtered' : ''}, '
      'page size ${widget.pageSize}, '
      'window margin ${widget.pageWindowMargin ?? 'none'}',
    );
    if (controller == null) {
      return ListTile(
        dense: true,
        title: const Text('opening...'),
        subtitle: subtitle,
      );
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListTile(
        dense: true,
        title: Text(
          'loaded ${controller.loadedItems.length} / '
          '${controller.totalCount ?? '?'} records',
        ),
        subtitle: subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.watch)
            IconButton(
              tooltip: 'Background writer',
              icon: Icon(_demoDb.isWriting ? Icons.pause : Icons.play_arrow),
              onPressed: () => setState(_demoDb.toggleWriter),
            ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.refresh(),
          ),
        ],
      ),
      body: _buildList(),
      bottomNavigationBar: SafeArea(
        child: Material(elevation: 3, child: _buildStatus()),
      ),
    );
  }
}
