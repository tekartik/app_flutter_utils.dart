import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

import 'sdb_join_list_controller.dart';

/// A ListView that lazily loads the rows of an sdb join query.
///
/// Each item is a [SdbJoinRow] holding a record of [source] and the record its
/// join key matched in [target], so a list showing a record together with the
/// one it points at needs a single query per page instead of one extra read
/// per row.
///
/// [source] is built with `asJoinSource` on a store (walked in primary key
/// order, its primary key being the join key) or on an index (walked in index
/// key order, its index key being the join key — the shape to prefer), or
/// with `asJoinSourceAt` on a store to read the join key from a field.
///
/// [target] is built with `asJoinTarget` on a store (matched on its primary
/// key, at most one record, so one row per source record) or on an index
/// (matched on its index key, any number of records, so a source record gives
/// one row per match).
///
/// Either provide an external [controller] (not disposed by this widget) or a
/// [client], [source] and [target] (with optional join options,
/// [findOptions], [watch] and [pageSize]) to let the widget create and own
/// its controller.
///
/// For more advanced layouts (e.g. inside a [CustomScrollView]), use a
/// [SdbJoinListController] with [SliverLazyList] or [LazyListViewDelegate].
class SdbJoinListView<
  K extends SdbKey,
  V extends SdbValue,
  SK extends SdbKey,
  JK extends SdbKey,
  JV extends SdbValue
>
    extends StatefulWidget {
  /// External controller, exclusive with [source].
  final SdbJoinListController<K, V, SK, JK, JV>? controller;

  /// Client (database or transaction) to use with [source].
  final SdbClient? client;

  /// What is iterated: a store or an index.
  final SdbJoinSource<K, V, SK>? source;

  /// What the join key is matched against: a store, on its primary key, or an
  /// index, on its index key.
  final SdbJoinTarget<JK, JV>? target;

  /// How the two sides are joined: `distinct`, `inner`, `chunkSize`.
  final SdbJoinFindOptions? joinOptions;

  /// Find options on the key the source is walked by: boundaries, filter,
  /// descending and an optional offset/limit window the list is restricted
  /// to.
  final SdbFindOptions<SK>? findOptions;

  /// When true, the query is watched and the list updates on changes of
  /// either store, [client] must be a [SdbDatabase].
  final bool watch;

  /// Page size for lazy loading.
  final int pageSize;

  /// Number of extra pages kept loaded around the visible range, see
  /// [LazyListController.pageWindowMargin]. Only used when this widget owns
  /// its controller.
  final int? pageWindowMargin;

  /// Item builder to display a loaded row.
  final Widget Function(
    BuildContext context,
    SdbJoinRow<K, V, JK, JV> row,
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

  /// Fixed extent of every item, strongly recommended on long lists, see
  /// [LazyListView.itemExtent].
  final double? itemExtent;

  /// Item used to measure the (fixed) item extent, see
  /// [LazyListView.itemExtent].
  final Widget? prototypeItem;

  /// Per index item extent, see [LazyListView.itemExtent].
  final ItemExtentBuilder? itemExtentBuilder;

  /// Constructor
  const SdbJoinListView({
    super.key,
    this.controller,
    this.client,
    this.source,
    this.target,
    this.joinOptions,
    this.findOptions,
    this.watch = false,
    this.pageSize = 50,
    this.pageWindowMargin = lazyListDefaultPageWindowMargin,
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
    this.itemExtent,
    this.prototypeItem,
    this.itemExtentBuilder,
  }) : assert(
         (controller != null) !=
             (client != null && source != null && target != null),
         'Provide either a controller or a client, a source and a target',
       );

  @override
  State<SdbJoinListView<K, V, SK, JK, JV>> createState() =>
      _SdbJoinListViewState<K, V, SK, JK, JV>();
}

class _SdbJoinListViewState<
  K extends SdbKey,
  V extends SdbValue,
  SK extends SdbKey,
  JK extends SdbKey,
  JV extends SdbValue
>
    extends State<SdbJoinListView<K, V, SK, JK, JV>> {
  SdbJoinListController<K, V, SK, JK, JV>? _ownedController;

  SdbJoinListController<K, V, SK, JK, JV> get _controller =>
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
        _ownedController = SdbJoinListController<K, V, SK, JK, JV>.watch(
          database: client,
          source: widget.source!,
          target: widget.target!,
          joinOptions: widget.joinOptions,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
          pageWindowMargin: widget.pageWindowMargin,
        );
      } else {
        _ownedController = SdbJoinListController<K, V, SK, JK, JV>(
          client: widget.client!,
          source: widget.source!,
          target: widget.target!,
          joinOptions: widget.joinOptions,
          findOptions: widget.findOptions,
          pageSize: widget.pageSize,
          pageWindowMargin: widget.pageWindowMargin,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant SdbJoinListView<K, V, SK, JK, JV> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.client != widget.client ||
        oldWidget.source != widget.source ||
        oldWidget.target != widget.target ||
        oldWidget.joinOptions != widget.joinOptions ||
        oldWidget.findOptions != widget.findOptions ||
        oldWidget.watch != widget.watch ||
        oldWidget.pageSize != widget.pageSize ||
        oldWidget.pageWindowMargin != widget.pageWindowMargin) {
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
    return LazyListView<SdbJoinRow<K, V, JK, JV>>(
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
      itemExtent: widget.itemExtent,
      prototypeItem: widget.prototypeItem,
      itemExtentBuilder: widget.itemExtentBuilder,
    );
  }
}
