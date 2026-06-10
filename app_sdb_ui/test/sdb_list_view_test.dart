import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

var simpleStore = SdbStoreRef<int, String>('simple');
var itemStore = SdbStoreRef<int, SdbModel>('item');
var nameIndex = itemStore.index<String>('name');

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

/// Pump until a widget is found, letting real async (database) work run.
/// A subsequent expect should report the failure if any.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
}

void main() {
  group('sdb list view', () {
    late SdbFactory factory;
    late SdbDatabase db;

    setUp(() async {
      factory = newSdbFactoryMemory();
      db = await factory.openDatabase(
        'test.db',
        options: SdbOpenDatabaseOptions(
          version: 1,
          onVersionChange: (e) {
            if (e.oldVersion < 1) {
              e.db.createStore(simpleStore);
              var openStore = e.db.createStore(itemStore);
              openStore.createIndex(nameIndex, 'name');
            }
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('SdbStoreListController basic logic', () async {
      for (var i = 0; i < 10; i++) {
        await simpleStore.record(i).put(db, 'item $i');
      }

      var controller = SdbStoreListController<int, String>(
        client: db,
        store: simpleStore,
        pageSize: 3,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.isInitialized, isTrue);
      expect(controller.totalCount, 10);

      expect(controller.getItem(0), isNull); // Loading started
      await waitUntil(() => controller.hasItem(0));
      expect(controller.getItem(0)?.value, 'item 0');
      expect(controller.getItem(2)?.value, 'item 2');
      expect(controller.getItem(3), isNull); // Page 1 loading started
      await waitUntil(() => controller.hasItem(3));
      expect(controller.getItem(3)?.value, 'item 3');
      controller.dispose();
    });

    test('SdbStoreListController with offset/limit window', () async {
      for (var i = 0; i < 10; i++) {
        await simpleStore.record(i).put(db, 'item $i');
      }

      // Window on items 2..6 (offset 2, limit 5)
      var controller = SdbStoreListController<int, String>(
        client: db,
        store: simpleStore,
        findOptions: SdbFindOptions(offset: 2, limit: 5),
        pageSize: 3,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 5);

      controller.getItem(0);
      controller.getItem(3);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(3));
      expect(controller.getItem(0)?.value, 'item 2');
      expect(controller.getItem(3)?.value, 'item 5');
      expect(controller.getItem(4)?.value, 'item 6');
      expect(controller.getItem(5), isNull);
      controller.dispose();
    });

    test('SdbStoreListController.watch updates on changes', () async {
      for (var i = 0; i < 3; i++) {
        await simpleStore.record(i).put(db, 'item $i');
      }

      var controller = SdbStoreListController<int, String>.watch(
        database: db,
        store: simpleStore,
        pageSize: 10,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(controller.getItem(0)?.value, 'item 0');

      // Add a record, count and page should update.
      await simpleStore.record(3).put(db, 'item 3');
      await waitUntil(() => controller.totalCount == 4);
      expect(controller.totalCount, 4);
      await waitUntil(() => controller.hasItem(3));
      expect(controller.getItem(3)?.value, 'item 3');

      // Update a record.
      await simpleStore.record(0).put(db, 'item 0 updated');
      await waitUntil(() => controller.getItem(0)?.value == 'item 0 updated');
      expect(controller.getItem(0)?.value, 'item 0 updated');
      controller.dispose();
    });

    test('SdbIndexListController basic logic', () async {
      await itemStore.add(db, {'name': 'cherry'});
      await itemStore.add(db, {'name': 'apple'});
      await itemStore.add(db, {'name': 'banana'});

      var controller = SdbIndexListController<int, SdbModel, String>(
        client: db,
        index: nameIndex,
        pageSize: 2,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      controller.getItem(0);
      controller.getItem(2);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(2));
      // Sorted by index key
      expect(controller.getItem(0)?.indexKey, 'apple');
      expect(controller.getItem(1)?.indexKey, 'banana');
      expect(controller.getItem(2)?.indexKey, 'cherry');
      controller.dispose();
    });

    test('SdbIndexListController with boundaries', () async {
      await itemStore.add(db, {'name': 'cherry'});
      await itemStore.add(db, {'name': 'apple'});
      await itemStore.add(db, {'name': 'banana'});

      var controller = SdbIndexListController<int, SdbModel, String>(
        client: db,
        index: nameIndex,
        findOptions: SdbFindOptions(
          boundaries: SdbBoundaries(nameIndex.lowerBoundary('banana'), null),
        ),
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 2);
      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(1));
      expect(controller.getItem(0)?.indexKey, 'banana');
      expect(controller.getItem(1)?.indexKey, 'cherry');
      controller.dispose();
    });

    testWidgets(
      'SdbStoreListView displays items',
      (tester) async {
        await tester.runAsync(() async {
          for (var i = 0; i < 5; i++) {
            await simpleStore.record(i).put(db, 'val $i');
          }
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SdbStoreListView<int, String>(
                client: db,
                store: simpleStore,
                pageSize: 2,
                itemBuilder: (context, snapshot, index) =>
                    SizedBox(height: 50, child: Text(snapshot.value)),
                loadingBuilder: (context, index) =>
                    const SizedBox(height: 50, child: Text('loading...')),
              ),
            ),
          ),
        );

        await pumpUntilFound(tester, find.text('val 4'));

        expect(find.text('val 0'), findsOneWidget);
        expect(find.text('val 1'), findsOneWidget);
        expect(find.text('val 4'), findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    testWidgets(
      'SdbStoreListView watch updates on changes',
      (tester) async {
        await tester.runAsync(() => simpleStore.record(0).put(db, 'first'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SdbStoreListView<int, String>(
                client: db,
                store: simpleStore,
                watch: true,
                itemBuilder: (context, snapshot, index) =>
                    SizedBox(height: 50, child: Text(snapshot.value)),
              ),
            ),
          ),
        );

        await pumpUntilFound(tester, find.text('first'));
        expect(find.text('first'), findsOneWidget);

        await tester.runAsync(() => simpleStore.record(1).put(db, 'second'));
        await pumpUntilFound(tester, find.text('second'));
        expect(find.text('second'), findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    testWidgets(
      'SdbIndexListView displays items',
      (tester) async {
        await tester.runAsync(() async {
          await itemStore.add(db, {'name': 'cherry'});
          await itemStore.add(db, {'name': 'apple'});
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SdbIndexListView<int, SdbModel, String>(
                client: db,
                index: nameIndex,
                itemBuilder: (context, snapshot, index) =>
                    SizedBox(height: 50, child: Text(snapshot.indexKey)),
              ),
            ),
          ),
        );

        await pumpUntilFound(tester, find.text('cherry'));
        expect(find.text('apple'), findsOneWidget);
        expect(find.text('cherry'), findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    testWidgets(
      'SdbStoreListView displays empty state',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SdbStoreListView<int, String>(
                client: db,
                store: simpleStore,
                itemBuilder: (context, snapshot, index) => Text(snapshot.value),
                emptyBuilder: (context) => const Text('empty'),
              ),
            ),
          ),
        );
        await pumpUntilFound(tester, find.text('empty'));
        expect(find.text('empty'), findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}
