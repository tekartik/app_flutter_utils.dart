import 'dart:async';

import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_list_view_flutter/list_view_flutter.dart';

import 'sdb_list_controller.dart';

/// Stream re-running [compute] whenever [store] or [targetStore] changes.
///
/// A join reads both stores, so a change on either one can change the rows.
/// [targetStore] is the store holding the joined records, whether they are
/// matched on its primary key or through one of its indexes.
Stream<T> _onJoinChanges<
  K extends SdbKey,
  V extends SdbValue,
  JK extends SdbKey,
  JV extends SdbValue,
  T
>(
  SdbDatabase database,
  SdbStoreRef<K, V> store,
  SdbStoreRef<JK, JV> targetStore,
  Future<T> Function() compute,
) {
  late StreamController<T> controller;
  // A self join would otherwise notify twice for every change.
  var watchesJoinStore = targetStore.name != store.name;

  void addResult() {
    compute().then(
      (result) {
        if (!controller.isClosed) {
          controller.add(result);
        }
      },
      onError: (Object e, StackTrace st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      },
    );
  }

  FutureOr<void> onStoreChange(
    SdbTransaction transaction,
    List<SdbRecordChange<K, V>> changes,
  ) {
    addResult();
  }

  FutureOr<void> onJoinStoreChange(
    SdbTransaction transaction,
    List<SdbRecordChange<JK, JV>> changes,
  ) {
    addResult();
  }

  controller = StreamController<T>(
    onListen: () {
      addResult();
      store.addOnChangesListener(database, onStoreChange);
      if (watchesJoinStore) {
        targetStore.addOnChangesListener(database, onJoinStoreChange);
      }
      controller.onCancel = () {
        store.removeOnChangesListener(database, onStoreChange);
        if (watchesJoinStore) {
          targetStore.removeOnChangesListener(database, onJoinStoreChange);
        }
      };
    },
  );
  return controller.stream;
}

/// Lazy list controller on an sdb join query.
///
/// Items are [SdbJoinRow]s loaded page by page: each one holds a record of
/// the iterated source and the record its join key matched.
///
/// The query is a [SdbJoinSource] and a [SdbJoinTarget], both of which can be
/// a store or an index, plus the join options ([SdbJoinFindOptions]:
/// `distinct`, `inner`) and optional find options on the source (boundaries,
/// filter, descending, and an optional offset/limit window, pages being
/// relative to the window).
///
/// ```dart
/// // Each book with its author: the join key is a field, the target matches
/// // it on its primary key, so one row per book.
/// SdbJoinListController<int, SdbModel, int, int, SdbModel>(
///   client: db,
///   source: bookStore.asJoinSourceAt('authorId'),
///   target: authorStore.asJoinTarget,
/// );
///
/// // Same, through the index on the join key: the shape to prefer, rows
/// // coming in author order.
/// SdbJoinListController<int, SdbModel, int, int, SdbModel>(
///   client: db,
///   source: bookAuthorIndex.asJoinSource,
///   target: authorStore.asJoinTarget,
/// );
///
/// // Each post with each of its comments: the target is an index, so a post
/// // with three comments gives three rows. The post primary key is the join
/// // key.
/// SdbJoinListController<int, SdbModel, int, int, SdbModel>(
///   client: db,
///   source: postStore.asJoinSource,
///   target: commentPostIndex.asJoinTarget,
/// );
/// ```
///
/// `findOptions` applies to the key the source is walked by: the primary key
/// of a store source, the index key of an index source.
class SdbJoinListController<
  K extends SdbKey,
  V extends SdbValue,
  SK extends SdbKey,
  JK extends SdbKey,
  JV extends SdbValue
>
    extends LazyListController<SdbJoinRow<K, V, JK, JV>> {
  /// One-shot query (Future based), [client] being a database or a
  /// transaction. A transaction must cover both stores.
  SdbJoinListController({
    required SdbClient client,
    required SdbJoinSource<K, V, SK> source,
    required SdbJoinTarget<JK, JV> target,
    SdbJoinFindOptions? joinOptions,
    SdbFindOptions<SK>? findOptions,
    super.pageSize,
    super.pageWindowMargin,
  }) : super(
         getItems: (offset, limit) async {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return <SdbJoinRow<K, V, JK, JV>>[];
           }
           return source.findJoinRows<JK, JV>(
             client,
             target: target,
             joinOptions: joinOptions,
             options: options,
           );
         },
         getCount: () async => sdbWindowCount(
           findOptions,
           await source.joinCount<JK, JV>(
             client,
             target: target,
             joinOptions: joinOptions,
             options: sdbCountFindOptions(findOptions),
           ),
         ),
       );

  /// Watching query (Stream based), pages and count are re-queried whenever
  /// either store changes.
  SdbJoinListController.watch({
    required SdbDatabase database,
    required SdbJoinSource<K, V, SK> source,
    required SdbJoinTarget<JK, JV> target,
    SdbJoinFindOptions? joinOptions,
    SdbFindOptions<SK>? findOptions,
    super.pageSize,
    super.pageWindowMargin,
  }) : super(
         watchItems: (offset, limit) {
           var options = sdbPageFindOptions(findOptions, offset, limit);
           if (options == null) {
             return Stream.value(<SdbJoinRow<K, V, JK, JV>>[]);
           }
           return _onJoinChanges(
             database,
             source.store,
             target.store,
             () => source.findJoinRows<JK, JV>(
               database,
               target: target,
               joinOptions: joinOptions,
               options: options,
             ),
           );
         },
         watchCount: () => _onJoinChanges(
           database,
           source.store,
           target.store,
           () async => sdbWindowCount(
             findOptions,
             await source.joinCount<JK, JV>(
               database,
               target: target,
               joinOptions: joinOptions,
               options: sdbCountFindOptions(findOptions),
             ),
           ),
         ),
       );
}
