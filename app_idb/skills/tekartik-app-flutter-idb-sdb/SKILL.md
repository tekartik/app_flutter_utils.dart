---
name: tekartik-app-flutter-idb-sdb
description: >-
  Use when a Flutter app needs a typed local database on every platform with
  the sdb (Simple DB) API of tekartik_app_flutter_idb: the
  package:tekartik_app_flutter_idb/sdb.dart import, the sdbFactory getter,
  getSdbFactory(packageName:), sdbFactoryMemory / newSdbFactoryMemory() for
  tests, SdbFactory.openDatabase with SdbOpenDatabaseOptions and
  onVersionChange, SdbStoreRef, SdbRecordRef, SdbModel, SdbDatabase,
  createStore, createIndex, add/put/getValue/delete, findRecords,
  SdbBoundaries, SdbFilter, SdbFindOptions, inStoreTransaction,
  inStoresTransaction and SdbTransactionMode.
---

# Typed local database with sdb (tekartik_app_flutter_idb)

`sdb` is the strongly typed, less verbose API that `idb_shim` layers on top of
an `IdbFactory`. This package wires it to the right platform implementation
(sqflite on mobile/desktop, native IndexedDB on the web) so a Flutter app gets
`SdbFactory` with no platform code.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_idb:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_idb
      version: '>=0.1.0'
  ```
* `package:tekartik_app_flutter_idb/sdb.dart` re-exports
  `package:idb_shim/sdb.dart` (all the `Sdb*` types) and adds:
  * `SdbFactory get sdbFactory` - the platform factory, built on the
    package's `idbFactory`.
  * `SdbFactory getSdbFactory({String? packageName})` - **prefer this one**.
    On linux and windows the `packageName` selects the databases directory
    (`<userAppDataPath>/<packageName>/databases`); elsewhere it is ignored.
  * `SdbFactory get sdbFactoryMemory` - in-memory, for tests.
  `newSdbFactoryMemory()` (a fresh, independent memory factory) comes from
  the re-export. Off a supported platform, reading `sdbFactory` throws
  `UnimplementedError`. Do not import `lib/src/`.
* Declare store references as top level constants, typed with the key and the
  value type: `var noteStore = SdbStoreRef<int, SdbModel>('note');`. `SdbKey`
  and `SdbValue` are `Object`, `SdbModel` is `Map<String, Object?>`. Indexes
  come from the store: `var titleIndex = noteStore.index<String>('title');`
  (`index2`/`index3`/`index4` for compound indexes).
* Open with
  `factory.openDatabase(name, options: SdbOpenDatabaseOptions(version: n,
  onVersionChange: (event) { ... }))`. Inside the callback use
  `event.oldVersion`, `event.newVersion` and `event.db`:
  `event.db.createStore(noteStore, keyPath:, autoIncrement:)` returns an
  `SdbOpenStoreRef` on which `createIndex(titleIndex, 'title', unique:)` /
  `createIndex2(...)` are called. `event.db.objectStore(store)`,
  `deleteStore(name)` and `objectStoreNames` handle migrations. Passing
  `version:`/`onVersionChange:` directly to `openDatabase` is deprecated:
  use `options:`.
* Read/write without an explicit transaction (each call is its own
  transaction) - every method takes the `SdbClient`, which is either the
  `SdbDatabase` or a transaction:
  * record level: `noteStore.record(key)` gives an `SdbRecordRef` with
    `put(client, value)`, `getValue(client)`, `get(client)` (a
    `SdbRecordSnapshot` with `key` and `value`), `exists(client)`,
    `delete(client)`.
  * store level: `noteStore.add(client, value)` (returns the generated key),
    `noteStore.put(client, value)` (inline keys), `noteStore.count(client)`,
    `noteStore.delete(client, ...)`, `noteStore.findRecords(client,
    boundaries:, filter:, offset:, limit:, descending:)` or the newer
    `options: SdbFindOptions(...)`, plus `findRecord`, `findRecordKeys`,
    `streamRecords` and `iterate(client, onRow:)`.
* Ranges and filters: `SdbBoundaries.values(lower, upper, includeLower:,
  includeUpper:)` (lower included, upper excluded by default),
  `SdbBoundaries.lowerValue(v)`, `SdbBoundaries.upperValue(v)`,
  `SdbBoundaries.key(k)`, or `SdbBoundaries(store.lowerBoundary(v,
  include: true), store.upperBoundary(v, include: false))` when you need to
  control inclusion boundary by boundary. `filter:` takes an `SdbFilter`
  (`SdbFilter.equals('field', value)`, ...) and is applied **in memory**
  after the boundaries, so keep boundaries selective.
* Group writes in a transaction: `db.inStoreTransaction(store,
  SdbTransactionMode.readWrite, (txn) async { ... })` gives a
  `SdbSingleStoreTransaction` with `add(value)`, `put(key, value)`,
  `getRecord(key)`, `delete(key)`, `findRecords(...)`, `findRecordKeys(...)`
  and `streamRecords(...)`; its `txnStore` gives the full
  `SdbTransactionStoreRef` (with `getValue`, `exists`, `count`,
  `deleteRecords`). `db.inStoresTransaction([s1, s2], mode, (txn) async {
  txn.store(s1) ... })` for several stores. Do not await anything unrelated
  inside a transaction: it commits when the callback returns.
* Index lookups: `titleIndex.findRecords(client, boundaries:, filter:,
  limit:)` returns `SdbIndexRecordSnapshot`s (`key`, `indexKey`, `value`),
  `titleIndex.record(indexKey)` gives a single index record ref.
* `db.close()` when done; `factory.deleteDatabase(name)` to reset.
* Testing: unit tests use `newSdbFactoryMemory()` (fresh per test) or
  `sdbFactoryMemory`. Take the `SdbFactory` as a parameter so the same code
  runs on device and in tests.
* Need the raw IndexedDB API instead (cursors, key ranges, existing idb
  code)? Use `package:tekartik_app_flutter_idb/idb.dart` - see the
  `tekartik-app-flutter-idb-setup` skill. Both libraries sit on the same
  underlying factory.

## Examples

### Schema, open and simple CRUD

```dart
import 'package:tekartik_app_flutter_idb/sdb.dart';

var noteStore = SdbStoreRef<int, SdbModel>('note');
var noteTitleIndex = noteStore.index<String>('title');

Future<SdbDatabase> openNotesDb(SdbFactory factory) => factory.openDatabase(
  'notes.db',
  options: SdbOpenDatabaseOptions(
    version: 1,
    onVersionChange: (event) {
      if (event.oldVersion < 1) {
        var store = event.db.createStore(noteStore);
        store.createIndex(noteTitleIndex, 'title');
      }
    },
  ),
);

Future<void> main() async {
  var factory = getSdbFactory(packageName: 'com.example.my_app');
  var db = await openNotesDb(factory);

  var key = await noteStore.add(db, {'title': 'hello', 'done': false});
  await noteStore.record(key).put(db, {'title': 'hello', 'done': true});

  var value = await noteStore.record(key).getValue(db);
  print('$key: $value');

  print('count: ${await noteStore.count(db)}');
  await noteStore.record(key).delete(db);

  await db.close();
}
```

### Queries: boundaries, filter, order and index

```dart
import 'package:tekartik_app_flutter_idb/sdb.dart';

var noteStore = SdbStoreRef<int, SdbModel>('note');
var noteTitleIndex = noteStore.index<String>('title');

Future<void> queries(SdbDatabase db) async {
  // The 20 last records, by key.
  var last = await noteStore.findRecords(db, limit: 20, descending: true);
  for (var snapshot in last) {
    print('${snapshot.key}: ${snapshot.value}');
  }

  // Keys 10 (included) to 20 (excluded).
  var range = await noteStore.findRecords(
    db,
    boundaries: SdbBoundaries.values(10, 20),
  );
  print('range: ${range.keys}');

  // In memory filter on top of a key range.
  var done = await noteStore.findRecords(
    db,
    options: SdbFindOptions<int>(
      filter: SdbFilter.equals('done', true),
      limit: 50,
    ),
  );
  print('done: ${done.values}');

  // By index, alphabetically from 'h'.
  var byTitle = await noteTitleIndex.findRecords(
    db,
    boundaries: SdbBoundaries.lowerValue('h'),
    limit: 10,
  );
  for (var snapshot in byTitle) {
    print('${snapshot.indexKey} -> ${snapshot.key} ${snapshot.value}');
  }
}
```

### Transactions

```dart
import 'package:tekartik_app_flutter_idb/sdb.dart';

var noteStore = SdbStoreRef<int, SdbModel>('note');
var tagStore = SdbStoreRef<String, SdbModel>('tag');

/// One store, one atomic unit.
Future<int> addAndCount(SdbDatabase db, SdbModel note) {
  return db.inStoreTransaction(noteStore, SdbTransactionMode.readWrite, (
    txn,
  ) async {
    await txn.add(note);
    return (await txn.findRecordKeys()).length;
  });
}

/// Several stores at once.
Future<void> addNoteWithTag(SdbDatabase db, SdbModel note, String tag) {
  return db.inStoresTransaction([noteStore, tagStore], SdbTransactionMode
      .readWrite, (txn) async {
    var key = await txn.store(noteStore).add(note);
    await txn.store(tagStore).put(tag, {'lastNote': key});
  });
}
```

### Injectable factory, memory in tests

```dart
import 'package:tekartik_app_flutter_idb/sdb.dart';

var prefsStore = SdbStoreRef<String, SdbModel>('prefs');

class Prefs {
  final SdbFactory factory;

  /// Defaults to the platform factory, tests pass a memory one.
  Prefs({SdbFactory? factory})
    : factory = factory ?? getSdbFactory(packageName: 'com.example.my_app');

  Future<SdbDatabase> _open() => factory.openDatabase(
    'prefs.db',
    options: SdbOpenDatabaseOptions(
      version: 1,
      onVersionChange: (event) {
        if (event.oldVersion < 1) {
          event.db.createStore(prefsStore);
        }
      },
    ),
  );

  Future<void> setValue(String key, Object? value) async {
    var db = await _open();
    await prefsStore.record(key).put(db, {'value': value});
    await db.close();
  }

  Future<Object?> getValue(String key) async {
    var db = await _open();
    var value = await prefsStore.record(key).getValue(db);
    await db.close();
    return value?['value'];
  }
}

Future<void> inTest() async {
  var prefs = Prefs(factory: newSdbFactoryMemory());
  await prefs.setValue('theme', 'dark');
  print(await prefs.getValue('theme'));
}
```

## Common mistakes

* Using `sdbFactory` on linux/windows instead of
  `getSdbFactory(packageName: ...)`: desktop builds then share one directory.
* Creating stores or indexes outside `onVersionChange`, or forgetting to bump
  `version` when the schema changes.
* Declaring the store ref with the wrong key type (`SdbStoreRef<String, ...>`
  for an auto increment store): keys are typed and checked.
* Relying on `filter:` for large stores - it runs in memory after the
  boundaries have been applied; add an index instead.
* Awaiting unrelated futures inside `inStoreTransaction` / `inStoresTransaction`.
* Storing class instances instead of `SdbModel` maps and primitives.
* Using the platform `sdbFactory` in a `flutter test` unit test: use
  `newSdbFactoryMemory()`.
