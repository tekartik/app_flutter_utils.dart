import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

var authorStore = SdbStoreRef<int, SdbModel>('author');
var bookStore = SdbStoreRef<int, SdbModel>('book');

/// Reviews of a book, several per book: the index makes it a one to many
/// join target.
var reviewStore = SdbStoreRef<int, SdbModel>('review');
var reviewBookIndex = reviewStore.index<int>('bookId');

/// The books indexed by author: the shape to prefer for a join, the index key
/// being the join key.
var bookAuthorIndex = bookStore.index<int>('authorId');

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
  group('sdb join list view', () {
    late SdbFactory factory;
    late SdbDatabase db;

    setUp(() async {
      factory = newSdbFactoryMemory();
      db = await factory.openDatabase(
        'join_test.db',
        options: SdbOpenDatabaseOptions(
          version: 1,
          onVersionChange: (e) {
            if (e.oldVersion < 1) {
              e.db.createStore(authorStore);
              e.db
                  .createStore(bookStore)
                  .createIndex(bookAuthorIndex, 'authorId');
              e.db
                  .createStore(reviewStore)
                  .createIndex(reviewBookIndex, 'bookId');
            }
          },
        ),
      );
      for (var i = 1; i <= 3; i++) {
        await authorStore.record(i).put(db, {'name': 'author$i'});
      }
      // 2 books on author 1, 1 on author 2, 1 without an author, 1 on an
      // author that does not exist, 1 on author 3.
      var books = <int, SdbModel>{
        1: {'title': 't1', 'authorId': 1},
        2: {'title': 't2', 'authorId': 1},
        3: {'title': 't3', 'authorId': 2},
        4: {'title': 't4'},
        5: {'title': 't5', 'authorId': 9},
        6: {'title': 't6', 'authorId': 3},
      };
      for (var entry in books.entries) {
        await bookStore.record(entry.key).put(db, entry.value);
      }
      // 2 reviews on book 1, 1 on book 3, none on the others.
      var reviews = <int, SdbModel>{
        21: {'text': 'r21', 'bookId': 1},
        22: {'text': 'r22', 'bookId': 1},
        23: {'text': 'r23', 'bookId': 3},
      };
      for (var entry in reviews.entries) {
        await reviewStore.record(entry.key).put(db, entry.value);
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('SdbJoinListController basic logic', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSourceAt('authorId'),
        target: authorStore.asJoinTarget,
        pageSize: 2,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 6);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(controller.getItem(0)?.record.value['title'], 't1');
      expect(controller.getItem(0)?.joinedRecord?.value['name'], 'author1');
      expect(controller.getItem(1)?.joinedRecord?.value['name'], 'author1');

      // Second page.
      controller.getItem(2);
      await waitUntil(() => controller.hasItem(2));
      expect(controller.getItem(2)?.joinedRecord?.value['name'], 'author2');
      expect(controller.getItem(3)?.joinedRecord, isNull);
      controller.dispose();
    });

    test('SdbJoinListController inner join count', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSourceAt('authorId'),
        target: authorStore.asJoinTarget,
        joinOptions: const SdbJoinFindOptions(inner: true),
        pageSize: 10,
      );

      await waitUntil(() => controller.isInitialized);
      // The 2 books without an existing author are dropped.
      expect(controller.totalCount, 4);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(List.generate(4, (i) => controller.getItem(i)?.record.key), [
        1,
        2,
        3,
        6,
      ]);
      controller.dispose();
    });

    test('SdbJoinListController distinct inner', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSourceAt('authorId'),
        target: authorStore.asJoinTarget,
        joinOptions: const SdbJoinFindOptions(distinct: true, inner: true),
        pageSize: 10,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(
        List.generate(3, (i) => controller.getItem(i)?.joinedRecord?.key),
        [1, 2, 3],
      );
      // Both sides are always carried now, the source record is never null.
      expect(controller.getItem(0)?.record.key, 1);
      controller.dispose();
    });

    test('SdbJoinListController with offset/limit window', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSourceAt('authorId'),
        target: authorStore.asJoinTarget,
        findOptions: SdbFindOptions(offset: 2, limit: 3),
        pageSize: 2,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      controller.getItem(0);
      controller.getItem(2);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(2));
      expect(List.generate(3, (i) => controller.getItem(i)?.record.key), [
        3,
        4,
        5,
      ]);
      controller.dispose();
    });

    test('SdbJoinListController.watch updates on either store', () async {
      var controller =
          SdbJoinListController<int, SdbModel, int, int, SdbModel>.watch(
            database: db,
            source: bookStore.asJoinSourceAt('authorId'),
            target: authorStore.asJoinTarget,
            pageSize: 10,
          );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 6);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(4));
      // Book 5 points at an author that does not exist yet.
      expect(controller.getItem(4)?.joinedRecord, isNull);

      // Creating that author must refresh the rows, the change being on the
      // joined store only.
      await authorStore.record(9).put(db, {'name': 'author9'});
      await waitUntil(
        () => controller.getItem(4)?.joinedRecord?.value['name'] == 'author9',
      );
      expect(controller.getItem(4)?.joinedRecord?.value['name'], 'author9');

      // A change on the iterated store refreshes too.
      await bookStore.record(7).put(db, {'title': 't7', 'authorId': 2});
      await waitUntil(() => controller.totalCount == 7);
      expect(controller.totalCount, 7);
      await waitUntil(() => controller.hasItem(6));
      expect(controller.getItem(6)?.joinedRecord?.value['name'], 'author2');
      controller.dispose();
    });

    test('SdbJoinListController on an index target, one to many', () async {
      // Each book with each of its reviews. No joinKeyPath: the book primary
      // key is the join key.
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSource,
        target: reviewBookIndex.asJoinTarget,
        pageSize: 10,
      );

      await waitUntil(() => controller.isInitialized);
      // Book 1 has two reviews so it gives two rows, book 3 one, and the
      // four books with none give one row each (left join).
      expect(controller.totalCount, 7);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(
        List.generate(
          7,
          (i) =>
              '${controller.getItem(i)?.record.key}->'
              '${controller.getItem(i)?.joinedRecord?.key}',
        ),
        ['1->21', '1->22', '2->null', '3->23', '4->null', '5->null', '6->null'],
      );
      controller.dispose();
    });

    test('SdbJoinListController on an index target, inner', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookStore.asJoinSource,
        target: reviewBookIndex.asJoinTarget,
        joinOptions: const SdbJoinFindOptions(inner: true),
        pageSize: 2,
      );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      controller.getItem(0);
      controller.getItem(2);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(2));
      expect(
        List.generate(3, (i) => controller.getItem(i)?.joinedRecord?.key),
        [21, 22, 23],
      );
      controller.dispose();
    });

    test('SdbJoinListController.watch on an index target', () async {
      var controller =
          SdbJoinListController<int, SdbModel, int, int, SdbModel>.watch(
            database: db,
            source: bookStore.asJoinSource,
            target: reviewBookIndex.asJoinTarget,
            joinOptions: const SdbJoinFindOptions(inner: true),
            pageSize: 10,
          );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 3);

      // A new review on the joined store adds a row.
      await reviewStore.record(24).put(db, {'text': 'r24', 'bookId': 2});
      await waitUntil(() => controller.totalCount == 4);
      expect(controller.totalCount, 4);
      controller.dispose();
    });

    testWidgets('SdbJoinListView on an index target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SdbJoinListView<int, SdbModel, int, int, SdbModel>(
              client: db,
              source: bookStore.asJoinSource,
              target: reviewBookIndex.asJoinTarget,
              joinOptions: const SdbJoinFindOptions(inner: true),
              pageSize: 10,
              itemBuilder: (context, row, index) => ListTile(
                title: Text('${row.record.value['title']}'),
                subtitle: Text('${row.joinedRecord?.value['text']}'),
              ),
            ),
          ),
        ),
      );

      await pumpUntilFound(tester, find.text('r21'));
      // Book 1 shows up once per review.
      expect(find.text('t1'), findsNWidgets(2));
      expect(find.text('r21'), findsOneWidget);
      expect(find.text('r22'), findsOneWidget);
      expect(find.text('r23'), findsOneWidget);
      // No review, dropped by the inner join.
      expect(find.text('t2'), findsNothing);
    });

    test('SdbJoinListController on an index source, index key order', () async {
      // The join key is the index key, so books with no authorId are not in
      // the index at all and never show up.
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookAuthorIndex.asJoinSource,
        target: authorStore.asJoinTarget,
        pageSize: 10,
      );

      await waitUntil(() => controller.isInitialized);
      // Books 1, 2, 3, 5, 6 have an authorId; book 4 has none.
      expect(controller.totalCount, 5);

      controller.getItem(0);
      await waitUntil(() => controller.hasItem(0));
      expect(
        List.generate(
          5,
          (i) =>
              '${controller.getItem(i)?.record.key}->'
              '${controller.getItem(i)?.joinedRecord?.key}',
        ),
        // Ordered by author id: books of author 1 first, then 2, 3, then the
        // book pointing at the author that does not exist.
        ['1->1', '2->1', '3->2', '6->3', '5->null'],
      );
      controller.dispose();
    });

    test('SdbJoinListController on an index source, boundaries', () async {
      var controller = SdbJoinListController<int, SdbModel, int, int, SdbModel>(
        client: db,
        source: bookAuthorIndex.asJoinSource,
        target: authorStore.asJoinTarget,
        joinOptions: const SdbJoinFindOptions(inner: true),
        findOptions: SdbFindOptions(boundaries: SdbBoundaries.values(1, 3)),
        pageSize: 2,
      );

      await waitUntil(() => controller.isInitialized);
      // Authors 1 and 2 only.
      expect(controller.totalCount, 3);

      controller.getItem(0);
      controller.getItem(2);
      await waitUntil(() => controller.hasItem(0) && controller.hasItem(2));
      expect(List.generate(3, (i) => controller.getItem(i)?.record.key), [
        1,
        2,
        3,
      ]);
      controller.dispose();
    });

    test('SdbJoinListController.watch on an index source', () async {
      var controller =
          SdbJoinListController<int, SdbModel, int, int, SdbModel>.watch(
            database: db,
            source: bookAuthorIndex.asJoinSource,
            target: authorStore.asJoinTarget,
            pageSize: 10,
          );

      await waitUntil(() => controller.isInitialized);
      expect(controller.totalCount, 5);

      // Giving book 4 an author puts it in the index.
      await bookStore.record(4).put(db, {'title': 't4', 'authorId': 2});
      await waitUntil(() => controller.totalCount == 6);
      expect(controller.totalCount, 6);
      controller.dispose();
    });

    testWidgets('SdbJoinListView on an index source', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SdbJoinListView<int, SdbModel, int, int, SdbModel>(
              client: db,
              source: bookAuthorIndex.asJoinSource,
              target: authorStore.asJoinTarget,
              joinOptions: const SdbJoinFindOptions(inner: true),
              pageSize: 10,
              itemBuilder: (context, row, index) => ListTile(
                title: Text('${row.record.value['title']}'),
                subtitle: Text('${row.joinedRecord?.value['name']}'),
              ),
            ),
          ),
        ),
      );

      await pumpUntilFound(tester, find.text('t1'));
      expect(find.text('t1'), findsOneWidget);
      expect(find.text('author1'), findsNWidgets(2));
      // No authorId, not in the index.
      expect(find.text('t4'), findsNothing);
      // Author does not exist, dropped by the inner join.
      expect(find.text('t5'), findsNothing);
    });

    testWidgets('SdbJoinListView on a store source with a key path', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SdbJoinListView<int, SdbModel, int, int, SdbModel>(
              client: db,
              source: bookStore.asJoinSourceAt('authorId'),
              target: authorStore.asJoinTarget,
              pageSize: 10,
              itemBuilder: (context, row, index) => ListTile(
                title: Text('${row.record.value['title']}'),
                subtitle: Text('${row.joinedRecord?.value['name']}'),
              ),
            ),
          ),
        ),
      );

      await pumpUntilFound(tester, find.text('t1'));
      expect(find.text('t1'), findsOneWidget);
      expect(find.text('author1'), findsNWidgets(2));
      expect(find.text('t4'), findsOneWidget);
      // Book 4 has no author id.
      expect(find.text('null'), findsNWidgets(2));
    });

    testWidgets('SdbJoinListView on a store source, inner join', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SdbJoinListView<int, SdbModel, int, int, SdbModel>(
              client: db,
              source: bookStore.asJoinSourceAt('authorId'),
              target: authorStore.asJoinTarget,
              joinOptions: const SdbJoinFindOptions(inner: true),
              pageSize: 10,
              itemBuilder: (context, row, index) =>
                  ListTile(title: Text('${row.record.value['title']}')),
            ),
          ),
        ),
      );

      await pumpUntilFound(tester, find.text('t1'));
      expect(find.text('t1'), findsOneWidget);
      expect(find.text('t6'), findsOneWidget);
      // Dropped by the inner join.
      expect(find.text('t4'), findsNothing);
      expect(find.text('t5'), findsNothing);
    });
  });
}
