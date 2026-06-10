import 'dart:async';

import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

/// Compose base find options with a page window (offset and limit).
///
/// The base offset/limit (if any) define a fixed window in the query results,
/// pages are relative to that window. Returns null when the page is outside
/// the window (i.e. the page is empty, no query needed).
SdbFindOptions<X>? sdbPageFindOptions<X extends SdbKey>(
  SdbFindOptions<X>? base,
  int offset,
  int limit,
) {
  var baseOffset = base?.offset ?? 0;
  var baseLimit = base?.limit;
  var pageLimit = limit;
  if (baseLimit != null) {
    var remaining = baseLimit - offset;
    if (remaining <= 0) {
      return null;
    }
    if (pageLimit > remaining) {
      pageLimit = remaining;
    }
  }
  return SdbFindOptions<X>(
    boundaries: base?.boundaries,
    filter: base?.filter,
    descending: base?.descending,
    offset: baseOffset + offset,
    limit: pageLimit,
  );
}

/// Find options to use for counting: keeps boundaries and filter, drops
/// offset/limit (applied afterwards through [sdbWindowCount]).
SdbFindOptions<X> sdbCountFindOptions<X extends SdbKey>(
  SdbFindOptions<X>? base,
) => SdbFindOptions<X>(boundaries: base?.boundaries, filter: base?.filter);

/// Adjust a raw query count to the window defined by the base find options
/// offset/limit.
int sdbWindowCount(SdbFindOptions? base, int rawCount) {
  var count = rawCount - (base?.offset ?? 0);
  if (count < 0) {
    count = 0;
  }
  var baseLimit = base?.limit;
  if (baseLimit != null && count > baseLimit) {
    count = baseLimit;
  }
  return count;
}

/// Count stream: emits the count and re-counts on every store change.
Stream<int> _onCount<K extends SdbKey, V extends SdbValue>(
  SdbDatabase database,
  SdbStoreRef<K, V> store,
  Future<int> Function() getCount,
) {
  late StreamController<int> controller;
  void addCount() {
    getCount().then(
      (count) {
        if (!controller.isClosed) {
          controller.add(count);
        }
      },
      onError: (Object e, StackTrace st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      },
    );
  }

  FutureOr<void> onChange(
    SdbTransaction transaction,
    List<SdbRecordChange<K, V>> changes,
  ) {
    addCount();
  }

  controller = StreamController<int>(
    onListen: () {
      addCount();
      store.addOnChangesListener(database, onChange);
      controller.onCancel = () {
        store.removeOnChangesListener(database, onChange);
      };
    },
  );
  return controller.stream;
}

/// Lazy list controller on an sdb store query.
///
/// Items are [SdbRecordSnapshot]s loaded page by page. The query is defined
/// by the store and optional find options (boundaries, filter, descending,
/// and an optional offset/limit window, pages being relative to the window).
class SdbStoreListController<K extends SdbKey, V extends SdbValue>
    extends LazyListController<SdbRecordSnapshot<K, V>> {
  /// One-shot query (Future based), [client] being a database or a
  /// transaction.
  SdbStoreListController({
    required SdbClient client,
    required SdbStoreRef<K, V> store,
    SdbFindOptions<K>? findOptions,
    super.pageSize,
  }) : super(
         getItems: (offset, limit) async {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return <SdbRecordSnapshot<K, V>>[];
           }
           return store.findRecords(client, options: options);
         },
         getCount: () async => sdbWindowCount(
           findOptions,
           await store.count(client, options: sdbCountFindOptions(findOptions)),
         ),
       );

  /// Watching query (Stream based), pages and count are re-queried whenever
  /// the store changes.
  SdbStoreListController.watch({
    required SdbDatabase database,
    required SdbStoreRef<K, V> store,
    SdbFindOptions<K>? findOptions,
    super.pageSize,
  }) : super(
         watchItems: (offset, limit) {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return Stream.value(<SdbRecordSnapshot<K, V>>[]);
           }
           return store.onSnapshots(database, options: options);
         },
         watchCount: () => _onCount(
           database,
           store,
           () async => sdbWindowCount(
             findOptions,
             await store.count(
               database,
               options: sdbCountFindOptions(findOptions),
             ),
           ),
         ),
       );
}

/// Lazy list controller on an sdb index query.
///
/// Items are [SdbIndexRecordSnapshot]s loaded page by page. The query is
/// defined by the index and optional find options on the index key
/// (boundaries, filter, descending, and an optional offset/limit window,
/// pages being relative to the window).
class SdbIndexListController<
  K extends SdbKey,
  V extends SdbValue,
  I extends SdbIndexKey
>
    extends LazyListController<SdbIndexRecordSnapshot<K, V, I>> {
  /// One-shot query (Future based), [client] being a database or a
  /// transaction.
  SdbIndexListController({
    required SdbClient client,
    required SdbIndexRef<K, V, I> index,
    SdbFindOptions<I>? findOptions,
    super.pageSize,
  }) : super(
         getItems: (offset, limit) async {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return <SdbIndexRecordSnapshot<K, V, I>>[];
           }
           return index.findRecords(client, options: options);
         },
         getCount: () async => sdbWindowCount(
           findOptions,
           await index.count(client, options: sdbCountFindOptions(findOptions)),
         ),
       );

  /// Watching query (Stream based), pages and count are re-queried whenever
  /// the index store changes.
  SdbIndexListController.watch({
    required SdbDatabase database,
    required SdbIndexRef<K, V, I> index,
    SdbFindOptions<I>? findOptions,
    super.pageSize,
  }) : super(
         watchItems: (offset, limit) {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return Stream.value(<SdbIndexRecordSnapshot<K, V, I>>[]);
           }
           return index.onSnapshots(database, options: options);
         },
         watchCount: () => _onCount(
           database,
           index.store,
           () async => sdbWindowCount(
             findOptions,
             await index.count(
               database,
               options: sdbCountFindOptions(findOptions),
             ),
           ),
         ),
       );
}
