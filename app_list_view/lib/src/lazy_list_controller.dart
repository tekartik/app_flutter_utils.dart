import 'dart:async';

import 'package:flutter/foundation.dart';

/// Fetches a page of items using offset and limit (Future based).
typedef LazyItemsGetter<T> = Future<List<T>> Function(int offset, int limit);

/// Watches a page of items using offset and limit (Stream based).
///
/// The stream can emit multiple times when the underlying data changes.
typedef LazyItemsStreamer<T> = Stream<List<T>> Function(int offset, int limit);

/// Fetches the total count of items (Future based).
typedef LazyCountGetter = Future<int> Function();

/// Watches the total count of items (Stream based).
///
/// The stream can emit multiple times when the underlying data changes.
typedef LazyCountStreamer = Stream<int> Function();

/// Controller managing paginated state and lazy-loading of items.
///
/// Items are fetched page by page (offset/limit), either through a Future
/// ([getItems]) or a Stream ([watchItems]). The total count can come from a
/// Future ([getCount]) or a Stream ([watchCount]). When no count source is
/// provided, the end of the list is inferred when a page returns fewer items
/// than requested.
class LazyListController<T> extends ChangeNotifier {
  /// Future based page fetch.
  final LazyItemsGetter<T>? getItems;

  /// Stream based page fetch, each page remains watched until [refresh] or
  /// [dispose].
  final LazyItemsStreamer<T>? watchItems;

  /// Future based count fetch.
  final LazyCountGetter? getCount;

  /// Stream based count fetch.
  final LazyCountStreamer? watchCount;

  /// Items per page.
  final int pageSize;

  final _items = <int, T>{};
  final _fetchingPages = <int>{};
  final _pageSubscriptions = <int, StreamSubscription<List<T>>>{};
  StreamSubscription<int>? _countSubscription;

  int? _totalCount;

  /// Page that inferred the current total count (no count source only), the
  /// total becomes unknown again if this page gets full on a later event.
  int? _inferredTotalPageIndex;
  Object? _error;
  StackTrace? _stackTrace;
  bool _isInitialized = false;
  bool _disposed = false;
  int _revision = 0;

  /// Requires exactly one of [getItems]/[watchItems] and at most one of
  /// [getCount]/[watchCount]. Future and Stream sources can be mixed.
  LazyListController({
    this.getItems,
    this.watchItems,
    this.getCount,
    this.watchCount,
    this.pageSize = 50,
  }) : assert(
         (getItems == null) != (watchItems == null),
         'Provide exactly one of getItems or watchItems',
       ),
       assert(
         getCount == null || watchCount == null,
         'Provide at most one of getCount or watchCount',
       ) {
    _init();
  }

  /// Future based controller.
  LazyListController.future({
    required LazyItemsGetter<T> getItems,
    LazyCountGetter? getCount,
    int pageSize = 50,
  }) : this(getItems: getItems, getCount: getCount, pageSize: pageSize);

  /// Stream based controller.
  LazyListController.stream({
    required LazyItemsStreamer<T> watchItems,
    LazyCountStreamer? watchCount,
    int pageSize = 50,
  }) : this(watchItems: watchItems, watchCount: watchCount, pageSize: pageSize);

  bool get _hasCountSource => getCount != null || watchCount != null;

  /// True when the initial count or setup is complete.
  bool get isInitialized => _isInitialized;

  /// Total count of items, if known (from the count source or inferred).
  int? get totalCount => _totalCount;

  /// Error if any operation failed.
  Object? get error => _error;

  /// StackTrace of the error if any.
  StackTrace? get stackTrace => _stackTrace;

  /// Currently loaded items by index.
  Map<int, T> get loadedItems => _items;

  /// True if the item at [index] is loaded.
  bool hasItem(int index) => _items.containsKey(index);

  /// Incremented on every change, allows delegates to know when to rebuild.
  int get revision => _revision;

  Future<void> _init() async {
    try {
      if (getCount != null) {
        var total = await getCount!();
        if (_disposed) return;
        _totalCount = total;
        _isInitialized = true;
        notifyListeners();
      } else if (watchCount != null) {
        _countSubscription = watchCount!().listen(
          (total) {
            _totalCount = total;
            _inferredTotalPageIndex = null;
            _isInitialized = true;
            notifyListeners();
          },
          onError: (Object e, StackTrace st) {
            _error = e;
            _stackTrace = st;
            _isInitialized = true;
            notifyListeners();
          },
        );
      } else {
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e, st) {
      if (_disposed) return;
      _error = e;
      _stackTrace = st;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Get item at index, triggers lazy-loading if not cached.
  ///
  /// Returns null while loading (use [hasItem] to disambiguate if T is
  /// nullable) or if the index is past the end.
  T? getItem(int index) {
    if (_items.containsKey(index)) {
      return _items[index];
    }
    if (_totalCount != null && index >= _totalCount!) {
      return null;
    }
    _loadPage(index ~/ pageSize);
    return null;
  }

  void _loadPage(int pageIndex) {
    var offset = pageIndex * pageSize;
    if (watchItems != null) {
      if (_pageSubscriptions.containsKey(pageIndex)) return;
      _pageSubscriptions[pageIndex] = watchItems!(offset, pageSize).listen(
        (items) {
          _applyPageResult(pageIndex, items);
        },
        onError: (Object e, StackTrace st) {
          _error = e;
          _stackTrace = st;
          notifyListeners();
        },
      );
    } else {
      if (_fetchingPages.contains(pageIndex)) return;
      _fetchingPages.add(pageIndex);
      () async {
        try {
          var items = await getItems!(offset, pageSize);
          if (_disposed) return;
          _fetchingPages.remove(pageIndex);
          _applyPageResult(pageIndex, items);
        } catch (e, st) {
          if (_disposed) return;
          _fetchingPages.remove(pageIndex);
          _error = e;
          _stackTrace = st;
          notifyListeners();
        }
      }();
    }
  }

  void _applyPageResult(int pageIndex, List<T> items) {
    var offset = pageIndex * pageSize;
    // Remove stale entries when the page shrank.
    for (var i = items.length; i < pageSize; i++) {
      _items.remove(offset + i);
    }
    for (var i = 0; i < items.length; i++) {
      _items[offset + i] = items[i];
    }
    if (items.length < pageSize) {
      // A short page marks the end of the list, also handles a count that
      // got stale (items deleted after a one-shot count).
      var newTotal = offset + items.length;
      if (_totalCount == null ||
          newTotal < _totalCount! ||
          _inferredTotalPageIndex == pageIndex) {
        _totalCount = newTotal;
        if (!_hasCountSource) {
          _inferredTotalPageIndex = pageIndex;
        }
      }
    } else if (!_hasCountSource && _inferredTotalPageIndex == pageIndex) {
      // The page that previously marked the end is full again, the total
      // is unknown again.
      _totalCount = null;
      _inferredTotalPageIndex = null;
    }
    notifyListeners();
  }

  /// Reset the controller and reload all data.
  void refresh() {
    _cancelSubscriptions();
    _items.clear();
    _fetchingPages.clear();
    _totalCount = null;
    _inferredTotalPageIndex = null;
    _error = null;
    _stackTrace = null;
    _isInitialized = false;
    notifyListeners();
    _init();
  }

  void _cancelSubscriptions() {
    for (var subscription in _pageSubscriptions.values) {
      subscription.cancel();
    }
    _pageSubscriptions.clear();
    _countSubscription?.cancel();
    _countSubscription = null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      _revision++;
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelSubscriptions();
    super.dispose();
  }
}
