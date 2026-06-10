import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'lazy_list_controller.dart';

/// Builds a widget for a loaded item.
typedef LazyItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// Builds a placeholder while the item at [index] is loading.
typedef LazyLoadingWidgetBuilder =
    Widget Function(BuildContext context, int index);

/// Builds an error widget.
typedef LazyErrorWidgetBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

Widget _defaultLoadingItem(BuildContext context, int index) => const SizedBox(
  height: 50,
  child: Center(child: CircularProgressIndicator()),
);

/// Sliver list delegate that builds widgets from a [LazyListController].
///
/// Can be used directly with [ListView.custom] or [SliverList] for full
/// custom list support.
class LazyListViewDelegate<T> extends SliverChildBuilderDelegate {
  /// The controller managing the state.
  final LazyListController<T> controller;

  /// Controller revision at build time, to detect needed rebuilds.
  final int _revision;

  /// Constructor
  LazyListViewDelegate({
    required this.controller,
    required LazyItemWidgetBuilder<T> itemBuilder,
    LazyLoadingWidgetBuilder? loadingBuilder,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback,
    super.semanticIndexOffset,
  }) : _revision = controller.revision,
       super((context, index) {
         if (controller.totalCount != null && index >= controller.totalCount!) {
           return null;
         }
         var item = controller.getItem(index);
         if (controller.hasItem(index)) {
           return itemBuilder(context, item as T, index);
         }
         return (loadingBuilder ?? _defaultLoadingItem)(context, index);
       }, childCount: controller.totalCount);

  @override
  bool shouldRebuild(covariant SliverChildBuilderDelegate oldDelegate) {
    if (oldDelegate is LazyListViewDelegate<T>) {
      return oldDelegate.controller != controller ||
          oldDelegate._revision != _revision;
    }
    return true;
  }
}

/// A lazy list sliver to use inside a [CustomScrollView].
class SliverLazyList<T> extends StatefulWidget {
  /// The controller managing the state, not disposed by this widget.
  final LazyListController<T> controller;

  /// Item builder to display a loaded item.
  final LazyItemWidgetBuilder<T> itemBuilder;

  /// Builder for placeholder while an item is loading.
  final LazyLoadingWidgetBuilder? loadingBuilder;

  /// Constructor
  const SliverLazyList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.loadingBuilder,
  });

  @override
  State<SliverLazyList<T>> createState() => _SliverLazyListState<T>();
}

class _SliverLazyListState<T> extends State<SliverLazyList<T>> {
  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SliverLazyList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: LazyListViewDelegate<T>(
        controller: widget.controller,
        itemBuilder: widget.itemBuilder,
        loadingBuilder: widget.loadingBuilder,
      ),
    );
  }
}

/// A ListView widget that lazily loads items by offset/limit on demand.
///
/// Either provide an external [controller] or the fetch callbacks
/// ([getItems]/[watchItems] and optionally [getCount]/[watchCount]) to let
/// the widget create and own its controller.
class LazyListView<T> extends StatefulWidget {
  /// External controller, not disposed by this widget. Exclusive with the
  /// fetch callbacks.
  final LazyListController<T>? controller;

  /// Future based page fetch.
  final LazyItemsGetter<T>? getItems;

  /// Stream based page fetch.
  final LazyItemsStreamer<T>? watchItems;

  /// Future based count fetch.
  final LazyCountGetter? getCount;

  /// Stream based count fetch.
  final LazyCountStreamer? watchCount;

  /// Page size for lazy loading (when the controller is owned).
  final int pageSize;

  /// Item builder to display a loaded item.
  final LazyItemWidgetBuilder<T> itemBuilder;

  /// Builder for placeholder while an item is loading.
  final LazyLoadingWidgetBuilder? loadingBuilder;

  /// Builder to show the initial loading state (before the count is known).
  final WidgetBuilder? initialLoadingBuilder;

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

  /// ListView configuration: addAutomaticKeepAlives.
  final bool addAutomaticKeepAlives;

  /// ListView configuration: addRepaintBoundaries.
  final bool addRepaintBoundaries;

  /// ListView configuration: addSemanticIndexes.
  final bool addSemanticIndexes;

  /// ListView configuration: cacheExtent.
  final ScrollCacheExtent? scrollCacheExtent;

  /// ListView configuration: dragStartBehavior.
  final DragStartBehavior dragStartBehavior;

  /// ListView configuration: keyboardDismissBehavior.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// ListView configuration: restorationId.
  final String? restorationId;

  /// ListView configuration: clipBehavior.
  final Clip clipBehavior;

  /// Constructor
  const LazyListView({
    super.key,
    this.controller,
    this.getItems,
    this.watchItems,
    this.getCount,
    this.watchCount,
    this.pageSize = 50,
    required this.itemBuilder,
    this.loadingBuilder,
    this.initialLoadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.scrollCacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : assert(
         (controller != null) != (getItems != null || watchItems != null),
         'Provide either a controller or fetch callbacks',
       );

  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
  LazyListController<T>? _ownedController;

  LazyListController<T> get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller == null) {
      _ownedController = LazyListController<T>(
        getItems: widget.getItems,
        watchItems: widget.watchItems,
        getCount: widget.getCount,
        watchCount: widget.watchCount,
        pageSize: widget.pageSize,
      );
    }
    _controller.addListener(_onControllerChanged);
  }

  void _disposeController() {
    _controller.removeListener(_onControllerChanged);
    _ownedController?.dispose();
    _ownedController = null;
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant LazyListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.getItems != widget.getItems ||
        oldWidget.watchItems != widget.watchItems ||
        oldWidget.getCount != widget.getCount ||
        oldWidget.watchCount != widget.watchCount ||
        oldWidget.pageSize != widget.pageSize) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _ownedController?.removeListener(_onControllerChanged);
      _ownedController?.dispose();
      _ownedController = null;
      _initController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isInitialized && _controller.error == null) {
      return widget.initialLoadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return widget.errorBuilder?.call(
            context,
            _controller.error!,
            _controller.stackTrace,
          ) ??
          Center(child: Text('Error: ${_controller.error}'));
    }

    if (_controller.totalCount == 0) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return ListView.custom(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      scrollCacheExtent: widget.scrollCacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      childrenDelegate: LazyListViewDelegate<T>(
        controller: _controller,
        itemBuilder: widget.itemBuilder,
        loadingBuilder: widget.loadingBuilder,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
      ),
    );
  }
}
