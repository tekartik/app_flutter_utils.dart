import 'package:flutter/material.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

import 'sdb_list_controller.dart';

/// A ListView that lazily loads the records of an sdb store query.
///
/// Either provide an external [controller] (not disposed by this widget) or
/// a [client] and [store] (with optional [findOptions], [watch] and
/// [pageSize]) to let the widget create and own its controller.
///
/// For more advanced layouts (e.g. inside a [CustomScrollView]), use a
/// [SdbStoreListController] with [SliverLazyList] or [LazyListViewDelegate].
class SdbStoreListView<K extends SdbKey, V extends SdbValue>
    extends StatefulWidget {
  /// External controller, exclusive with [store].
  final SdbStoreListController<K, V>? controller;

  /// Client (database or transaction) to use with [store].
  final SdbClient? client;

  /// The store to query.
  final SdbStoreRef<K, V>? store;

  /// Find options: boundaries, filter, descending and an optional
  /// offset/limit window the list is restricted to.
  final SdbFindOptions<K>? findOptions;

  /// When true, the query is watched and the list updates on store changes,
  /// [client] must be a [SdbDatabase].
  final bool watch;

  /// Page size for lazy loading.
  final int pageSize;

  /// Item builder to display a loaded record.
  final Widget Function(
    BuildContext context,
    SdbRecordSnapshot<K, V> snapshot,
    int index,
  )
  itemBuilder;

  /// Builder for placeholder while an item is loading.
  final LazyItemLoadingWidgetBuilder? itemLoadingBuilder;

  /// Builder for the global loading state, shown until the first data is
  /// available.
  final WidgetBuilder? loadingBuilder;

  /// Builder to show error state.
  final LazyErrorWidgetBuilder? errorBuilder;

  /// Builder to show empty state.
  final WidgetBuilder? emptyBuilder;

  /// ListView configuration: scroll direction.
  final Axis scrollDirection;

  /// ListView configuration: reverse.
  final bool reverse;

  /// ListView configuration: scroll controller.
  final ScrollController? scrollController;

  /// ListView configuration: primary.
  final bool? primary;

  /// ListView configuration: physics.
  final ScrollPhysics? physics;

  /// ListView configuration: shrinkWrap.
  final bool shrinkWrap;

  /// ListView configuration: padding.
  final EdgeInsetsGeometry? padding;

  /// Constructor
  const SdbStoreListView({
    super.key,
    this.controller,
    this.client,
    this.store,
    this.findOptions,
    this.watch = false,
    this.pageSize = 50,
    required this.itemBuilder,
    this.itemLoadingBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  }) : assert(
         (controller != null) != (store != null && client != null),
         'Provide either a controller or a client and a store',
       );

  @override
  State<SdbStoreListView<K, V>> createState() => _SdbStoreListViewState<K, V>();
}

class _SdbStoreListViewState<K extends SdbKey, V extends SdbValue>
    extends State<SdbStoreListView<K, V>> {
  SdbStoreListController<K, V>? _ownedController;

  SdbStoreListController<K, V> get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller == null) {
      if (widget.watch) {
        var client = widget.client;
        if (client is! SdbDatabase) {
          throw ArgumentError(
            'client must be a SdbDatabase when watch is true',
          );
        }
        _ownedController = SdbStoreListController<K, V>.watch(
          database: client,
          store: widget.store!,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
        );
      } else {
        _ownedController = SdbStoreListController<K, V>(
          client: widget.client!,
          store: widget.store!,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant SdbStoreListView<K, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.client != widget.client ||
        oldWidget.store != widget.store ||
        oldWidget.findOptions != widget.findOptions ||
        oldWidget.watch != widget.watch ||
        oldWidget.pageSize != widget.pageSize) {
      _ownedController?.dispose();
      _ownedController = null;
      _initController();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LazyListView<SdbRecordSnapshot<K, V>>(
      controller: _controller,
      itemBuilder: widget.itemBuilder,
      itemLoadingBuilder: widget.itemLoadingBuilder,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      emptyBuilder: widget.emptyBuilder,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      scrollController: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }
}

/// A ListView that lazily loads the records of an sdb index query.
///
/// Either provide an external [controller] (not disposed by this widget) or
/// a [client] and [index] (with optional [findOptions], [watch] and
/// [pageSize]) to let the widget create and own its controller.
///
/// For more advanced layouts (e.g. inside a [CustomScrollView]), use a
/// [SdbIndexListController] with [SliverLazyList] or [LazyListViewDelegate].
class SdbIndexListView<
  K extends SdbKey,
  V extends SdbValue,
  I extends SdbIndexKey
>
    extends StatefulWidget {
  /// External controller, exclusive with [index].
  final SdbIndexListController<K, V, I>? controller;

  /// Client (database or transaction) to use with [index].
  final SdbClient? client;

  /// The index to query.
  final SdbIndexRef<K, V, I>? index;

  /// Find options on the index key: boundaries, filter, descending and an
  /// optional offset/limit window the list is restricted to.
  final SdbFindOptions<I>? findOptions;

  /// When true, the query is watched and the list updates on store changes,
  /// [client] must be a [SdbDatabase].
  final bool watch;

  /// Page size for lazy loading.
  final int pageSize;

  /// Item builder to display a loaded record.
  final Widget Function(
    BuildContext context,
    SdbIndexRecordSnapshot<K, V, I> snapshot,
    int index,
  )
  itemBuilder;

  /// Builder for placeholder while an item is loading.
  final LazyItemLoadingWidgetBuilder? itemLoadingBuilder;

  /// Builder for the global loading state, shown until the first data is
  /// available.
  final WidgetBuilder? loadingBuilder;

  /// Builder to show error state.
  final LazyErrorWidgetBuilder? errorBuilder;

  /// Builder to show empty state.
  final WidgetBuilder? emptyBuilder;

  /// ListView configuration: scroll direction.
  final Axis scrollDirection;

  /// ListView configuration: reverse.
  final bool reverse;

  /// ListView configuration: scroll controller.
  final ScrollController? scrollController;

  /// ListView configuration: primary.
  final bool? primary;

  /// ListView configuration: physics.
  final ScrollPhysics? physics;

  /// ListView configuration: shrinkWrap.
  final bool shrinkWrap;

  /// ListView configuration: padding.
  final EdgeInsetsGeometry? padding;

  /// Constructor
  const SdbIndexListView({
    super.key,
    this.controller,
    this.client,
    this.index,
    this.findOptions,
    this.watch = false,
    this.pageSize = 50,
    required this.itemBuilder,
    this.itemLoadingBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  }) : assert(
         (controller != null) != (index != null && client != null),
         'Provide either a controller or a client and an index',
       );

  @override
  State<SdbIndexListView<K, V, I>> createState() =>
      _SdbIndexListViewState<K, V, I>();
}

class _SdbIndexListViewState<
  K extends SdbKey,
  V extends SdbValue,
  I extends SdbIndexKey
>
    extends State<SdbIndexListView<K, V, I>> {
  SdbIndexListController<K, V, I>? _ownedController;

  SdbIndexListController<K, V, I> get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller == null) {
      if (widget.watch) {
        var client = widget.client;
        if (client is! SdbDatabase) {
          throw ArgumentError(
            'client must be a SdbDatabase when watch is true',
          );
        }
        _ownedController = SdbIndexListController<K, V, I>.watch(
          database: client,
          index: widget.index!,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
        );
      } else {
        _ownedController = SdbIndexListController<K, V, I>(
          client: widget.client!,
          index: widget.index!,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant SdbIndexListView<K, V, I> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.client != widget.client ||
        oldWidget.index != widget.index ||
        oldWidget.findOptions != widget.findOptions ||
        oldWidget.watch != widget.watch ||
        oldWidget.pageSize != widget.pageSize) {
      _ownedController?.dispose();
      _ownedController = null;
      _initController();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LazyListView<SdbIndexRecordSnapshot<K, V, I>>(
      controller: _controller,
      itemBuilder: widget.itemBuilder,
      itemLoadingBuilder: widget.itemLoadingBuilder,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      emptyBuilder: widget.emptyBuilder,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      scrollController: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }
}
