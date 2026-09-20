---
name: tekartik-app-flutter-idb-setup
description: >-
  Use when a Flutter app needs a local indexed-db style database on every
  platform (android, ios, linux, macos, windows, web) with
  tekartik_app_flutter_idb: the package:tekartik_app_flutter_idb/idb.dart
  import, the idbFactory getter, getIdbFactory(packageName:), idbFactoryMemory
  and newIdbFactoryMemory() for tests, and the idb_shim API - IdbFactory.open
  with version/onUpgradeNeeded, Database, VersionChangeEvent,
  createObjectStore, Transaction, ObjectStore put/add/getObject/delete/count,
  openCursor, Index, KeyRange, idbModeReadOnly, idbModeReadWrite.
---

# Cross platform idb factory for a Flutter app (tekartik_app_flutter_idb)

This package gives a Flutter app one `IdbFactory` that works everywhere:
sqflite on android/ios/macos, sqflite-ffi (through `tekartik_app_flutter_sqflite`)
on linux/windows, the browser's native IndexedDB on the web. App code writes
plain `idb_shim` code and never picks an implementation.

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
* `package:tekartik_app_flutter_idb/idb.dart` re-exports
  `package:idb_shim/idb_shim.dart` (`IdbFactory`, `Database`, `Transaction`,
  `ObjectStore`, `Index`, `KeyRange`, `Cursor`, `CursorWithValue`,
  `VersionChangeEvent`, `DatabaseException`, `idbModeReadOnly`,
  `idbModeReadWrite`, `idbDirectionNext`, `idbDirectionPrev`,
  `newIdbFactoryMemory()`, `idbFactoryNative`) and adds three members:
  * `IdbFactory get idbFactory` - the platform factory. Resolved by
    conditional import: `dart:io` builds use sqflite, `dart:js_interop`
    builds use `idbFactoryNative`, other targets get a stub that throws
    `UnimplementedError`.
  * `IdbFactory getIdbFactory({String? packageName})` - **prefer this one**.
    Same as `idbFactory` except on linux and windows, where it builds an
    sqflite-ffi factory whose databases live under
    `<userAppDataPath>/<packageName>/databases`. Pass a reverse-dns
    `packageName` so desktop builds do not share one directory. Results are
    cached per `packageName`.
  * `IdbFactory get idbFactoryMemory` - the in-memory factory, for tests and
    scratch data.
  Never import anything under `lib/src/`.
* Never import `package:idb_shim/idb_browser.dart`, `idb_client_sqflite.dart`
  or `sqflite` directly in app code: that is exactly what this package hides.
* Open a database with `factory.open(name, version: n, onUpgradeNeeded: (e) {
  ... })`. Inside the callback use `e.oldVersion`, `e.newVersion`,
  `e.database.createObjectStore(name, keyPath:, autoIncrement:)` and
  `objectStore.createIndex(name, keyPath, unique:, multiEntry:)`. The callback
  runs in the version-change transaction; it may be async but must not await
  anything outside it.
* Read/write through a transaction:
  `var txn = db.transaction(storeName, idbModeReadWrite);` then
  `txn.objectStore(storeName)`, and `await txn.completed` before considering
  the write durable. `db.transactionList([...], mode)` opens several stores
  at once. `db.close()` when done.
* `ObjectStore`: `add(value, [key])` (insert only, returns the key),
  `put(value, [key])` (insert or update), `getObject(key)`, `getKey(key)`,
  `getAll([query, count])`, `getAllKeys(...)`, `delete(keyOrRange)`,
  `clear()`, `count([keyOrRange])`, `openCursor(key:, range:, direction:,
  autoAdvance:)`, `openKeyCursor(...)`, `index(name)`. Values are structured
  clones: use maps, lists, numbers, strings, bools - not arbitrary objects.
* Out-of-line keys (`put(value, key)`) require a store created without
  `keyPath`; inline keys (`put(value)`) require `keyPath:` (or
  `autoIncrement: true` with `add`). Mixing both throws at runtime.
* Cursors are `Stream`s: `store.openCursor(autoAdvance: true).toList()` or
  `await for (var cursor in ...)`, calling `cursor.next()` yourself when
  `autoAdvance` is not set.
* `KeyRange.only/lowerBound/upperBound/bound(...)` builds ranges for
  `count`, `delete`, `openCursor` and `Index` lookups.
* Testing: unit tests (`flutter test`, no device) must use
  `idbFactoryMemory` or a fresh `newIdbFactoryMemory()`; the platform
  `idbFactory` needs a real device/browser. Take the `IdbFactory` as a
  constructor parameter so the same code runs against both.
* If you want a typed, less verbose API on top of the same factory, use
  `package:tekartik_app_flutter_idb/sdb.dart` instead (see the
  `tekartik-app-flutter-idb-sdb` skill).

## Examples

### Open a database and toggle a value

```dart
import 'package:tekartik_app_flutter_idb/idb.dart';

var storeName = 'main';

Future<Database> openDb(IdbFactory factory) => factory.open(
  'app.db',
  version: 1,
  onUpgradeNeeded: (event) {
    if (event.oldVersion < 1) {
      event.database.createObjectStore(storeName);
    }
  },
);

Future<void> main() async {
  var factory = getIdbFactory(packageName: 'com.example.my_app');
  var db = await openDb(factory);

  var toggle =
      await db
              .transaction(storeName, idbModeReadOnly)
              .objectStore(storeName)
              .getObject('toggle')
          as bool?;
  toggle = !(toggle ?? false);

  var txn = db.transaction(storeName, idbModeReadWrite);
  await txn.objectStore(storeName).put(toggle, 'toggle');
  await txn.completed;

  db.close();
}
```

### Auto increment store with an index and a cursor query

```dart
import 'package:tekartik_app_flutter_idb/idb.dart';

var notesStore = 'notes';
var titleIndex = 'title';

Future<Database> openNotesDb(IdbFactory factory) => factory.open(
  'notes.db',
  version: 1,
  onUpgradeNeeded: (event) {
    if (event.oldVersion < 1) {
      var store = event.database.createObjectStore(
        notesStore,
        autoIncrement: true,
      );
      store.createIndex(titleIndex, 'title', unique: false);
    }
  },
);

Future<int> addNote(Database db, String title, String body) async {
  var txn = db.transaction(notesStore, idbModeReadWrite);
  var key = await txn.objectStore(notesStore).add({
    'title': title,
    'body': body,
  });
  await txn.completed;
  return key as int;
}

Future<List<Object?>> notesByTitle(Database db, String prefix) async {
  var txn = db.transaction(notesStore, idbModeReadOnly);
  var index = txn.objectStore(notesStore).index(titleIndex);
  var rows = await index
      .openCursor(
        range: KeyRange.bound(prefix, '$prefix￿'),
        autoAdvance: true,
      )
      .map((cursor) => cursor.value)
      .toList();
  await txn.completed;
  return rows;
}
```

### Injectable factory, memory in tests

```dart
import 'package:tekartik_app_flutter_idb/idb.dart';

class AppDb {
  final IdbFactory factory;
  static const _storeName = 'prefs';

  /// Defaults to the platform factory, tests pass a memory one.
  AppDb({IdbFactory? factory})
    : factory = factory ?? getIdbFactory(packageName: 'com.example.my_app');

  Future<Database> open() => factory.open(
    'prefs.db',
    version: 1,
    onUpgradeNeeded: (event) {
      if (event.oldVersion < 1) {
        event.database.createObjectStore(_storeName);
      }
    },
  );

  Future<void> setValue(String key, Object value) async {
    var db = await open();
    var txn = db.transaction(_storeName, idbModeReadWrite);
    await txn.objectStore(_storeName).put(value, key);
    await txn.completed;
    db.close();
  }
}

Future<void> inTest() async {
  var appDb = AppDb(factory: newIdbFactoryMemory());
  await appDb.setValue('theme', 'dark');
}
```

### Deleting a database and upgrading a schema

```dart
import 'package:tekartik_app_flutter_idb/idb.dart';

Future<Database> openV2(IdbFactory factory) => factory.open(
  'app.db',
  version: 2,
  onUpgradeNeeded: (event) {
    var db = event.database;
    if (event.oldVersion < 1) {
      db.createObjectStore('main');
    }
    if (event.oldVersion < 2) {
      // Added in version 2.
      db.createObjectStore('cache', autoIncrement: true);
    }
  },
);

Future<void> reset(IdbFactory factory) async {
  await factory.deleteDatabase('app.db');
}
```

## Common mistakes

* Using `idbFactory` on linux/windows instead of
  `getIdbFactory(packageName: ...)`: the databases then land in a shared
  default directory.
* Forgetting `await txn.completed` and closing the database (or asserting a
  read) before the write landed.
* Doing an `await` on something unrelated inside a transaction: the
  transaction auto-commits and later calls throw.
* Calling `createObjectStore` / `createIndex` outside `onUpgradeNeeded`.
* Passing an explicit key to a store that has a `keyPath`, or omitting the
  key on a store that has none.
* Storing class instances instead of maps/lists/primitives.
* Using the platform `idbFactory` in a `flutter test` unit test: use
  `idbFactoryMemory` / `newIdbFactoryMemory()`.
