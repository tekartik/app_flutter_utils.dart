import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/sdb.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

var authorStore = SdbStoreRef<int, SdbModel>('author');
var bookStore = SdbStoreRef<int, SdbModel>('book');
var bookAuthorIndex = bookStore.index<int>('authorId');

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

/// Pump a few frames, letting the (real) database queries run.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
}

void main() {
  late SdbDatabase db;
  setUp(() async {
    db = await newSdbFactoryMemory().openDatabase(
      'rebuild.db',
      options: SdbOpenDatabaseOptions(
        version: 1,
        onVersionChange: (e) {
          e.db.createStore(authorStore);
          var store = e.db.createStore(bookStore);
          store.createIndex(bookAuthorIndex, 'authorId');
        },
      ),
    );
    await authorStore.record(1).put(db, {'name': 'author1'});
    for (var i = 0; i < 200; i++) {
      await bookStore.record(i).put(db, {'title': 't$i', 'authorId': 1});
    }
  });
  tearDown(() => db.close());

  Widget itemFor(String title) => SizedBox(height: 50, child: Text(title));

  /// Scroll to item 100, rebuild the parent (with [changeArgs] toggled when
  /// given) and return true if the list was reloaded.
  Future<bool> rebuildReloads(
    WidgetTester tester,
    Widget Function(ScrollController sc, bool changed) buildList, {
    bool changeArgs = false,
  }) async {
    var sc = ScrollController();
    addTearDown(sc.dispose);
    late StateSetter rebuild;
    var changed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return buildList(sc, changed);
            },
          ),
        ),
      ),
    );
    await pumpUntilFound(tester, find.text('t0'));
    expect(find.text('t0'), findsOneWidget);
    sc.jumpTo(50.0 * 100);
    await pumpUntilFound(tester, find.text('t100'));
    expect(find.text('t100'), findsOneWidget);

    rebuild(() {
      changed = changeArgs;
    });
    await pumpFrames(tester);
    var reloaded = find.text('t100').evaluate().isEmpty;
    if (!reloaded) {
      expect(sc.offset, 5000);
    }
    return reloaded;
  }

  group('parent rebuild with equal inline arguments keeps the list', () {
    testWidgets('SdbJoinListView', (tester) async {
      expect(
        await rebuildReloads(
          tester,
          (sc, _) => SdbJoinListView<int, SdbModel, int, int, SdbModel>(
            client: db,
            source: bookStore.asJoinSourceAt('authorId'),
            target: authorStore.asJoinTarget,
            joinOptions: const SdbJoinFindOptions(),
            findOptions: SdbFindOptions(
              boundaries: SdbBoundaries(bookStore.lowerBoundary(0), null),
            ),
            pageSize: 20,
            itemExtent: 50,
            scrollController: sc,
            itemBuilder: (context, row, index) =>
                itemFor('${row.record.value['title']}'),
          ),
        ),
        isFalse,
      );
    });

    testWidgets('SdbStoreListView', (tester) async {
      expect(
        await rebuildReloads(
          tester,
          (sc, _) => SdbStoreListView<int, SdbModel>(
            client: db,
            store: bookStore,
            findOptions: SdbFindOptions(
              boundaries: SdbBoundaries(bookStore.lowerBoundary(0), null),
              filter: SdbFilter.equals('authorId', 1),
            ),
            pageSize: 20,
            itemExtent: 50,
            scrollController: sc,
            itemBuilder: (context, snapshot, index) =>
                itemFor('${snapshot.value['title']}'),
          ),
        ),
        isFalse,
      );
    });

    testWidgets('SdbIndexListView', (tester) async {
      expect(
        await rebuildReloads(
          tester,
          (sc, _) => SdbIndexListView<int, SdbModel, int>(
            client: db,
            index: bookStore.index<int>('authorId'),
            findOptions: SdbFindOptions(
              boundaries: SdbBoundaries(bookAuthorIndex.lowerBoundary(1), null),
            ),
            pageSize: 20,
            itemExtent: 50,
            scrollController: sc,
            itemBuilder: (context, snapshot, index) =>
                itemFor('${snapshot.value['title']}'),
          ),
        ),
        isFalse,
      );
    });
  });

  testWidgets('SdbStoreListView reloads when the boundaries change', (
    tester,
  ) async {
    expect(
      await rebuildReloads(
        tester,
        (sc, changed) => SdbStoreListView<int, SdbModel>(
          client: db,
          store: bookStore,
          findOptions: SdbFindOptions(
            boundaries: SdbBoundaries(
              bookStore.lowerBoundary(changed ? 150 : 0),
              null,
            ),
          ),
          pageSize: 20,
          itemExtent: 50,
          scrollController: sc,
          itemBuilder: (context, snapshot, index) =>
              itemFor('${snapshot.value['title']}'),
        ),
        changeArgs: true,
      ),
      isTrue,
    );
  });
}
