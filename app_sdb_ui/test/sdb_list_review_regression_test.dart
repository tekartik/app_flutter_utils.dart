import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart' as idb;
import 'package:idb_shim/sdb.dart';
// Test only: the raw idb database and the cross-tab notification hook, as in
// idb_shim's own sdb_cross_tab_test.
// ignore: implementation_imports
import 'package:idb_shim/src/sdb/sdb_database_impl.dart'
    show SdbDatabaseIdbExt, SdbDatabaseInternalExtension;
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

var itemStore = SdbStoreRef<int, SdbModel>('item');
var nameIndex = itemStore.index<String>('name');

/// Write directly to the underlying idb database, bypassing the sdb change
/// listeners: what another browser tab does.
Future<void> writeFromOtherTab(
  SdbDatabase db,
  String storeName,
  Object key,
  Object value,
) async {
  var txn = db.rawIdb.transaction(storeName, idb.idbModeReadWrite);
  await txn.objectStore(storeName).put(value, key);
  await txn.completed;
}

/// Wait (real async) until a condition is met, a subsequent expect should
/// report the failure if any.
Future<void> waitUntil(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late SdbDatabase db;
  setUp(() async {
    db = await newSdbFactoryMemory().openDatabase(
      'review.db',
      options: SdbOpenDatabaseOptions(
        version: 1,
        onVersionChange: (e) {
          var store = e.db.createStore(itemStore);
          store.createIndex(nameIndex, 'name');
        },
      ),
    );
    for (var i = 0; i < 3; i++) {
      await itemStore.record(i).put(db, {'name': 'n$i', 'tag': 'a', 'rank': i});
    }
  });
  tearDown(() => db.close());

  group('watched count follows the changes of another tab', () {
    test('SdbStoreListController.watch', () async {
      var controller = SdbStoreListController<int, SdbModel>.watch(
        database: db,
        store: itemStore,
        pageSize: 10,
      );
      addTearDown(controller.dispose);
      await waitUntil(() => controller.totalCount == 3);
      expect(controller.totalCount, 3);
      controller.getItem(0);
      await waitUntil(() => controller.hasItem(2));

      await writeFromOtherTab(db, itemStore.name, 3, {
        'name': 'n3',
        'tag': 'a',
        'rank': 3,
      });
      db.impl.simulateExternalStoreChanges([itemStore.name]);
      await waitUntil(() => controller.totalCount == 4);
      expect(controller.totalCount, 4);
    });

    test('SdbIndexListController.watch', () async {
      var controller = SdbIndexListController<int, SdbModel, String>.watch(
        database: db,
        index: nameIndex,
        pageSize: 10,
      );
      addTearDown(controller.dispose);
      await waitUntil(() => controller.totalCount == 3);
      expect(controller.totalCount, 3);

      await writeFromOtherTab(db, itemStore.name, 3, {
        'name': 'n3',
        'tag': 'a',
        'rank': 3,
      });
      db.impl.simulateExternalStoreChanges([itemStore.name]);
      await waitUntil(() => controller.totalCount == 4);
      expect(controller.totalCount, 4);
    });
  });
}
