---
name: tekartik-app-flutter-sembast-setup
description: >-
  Use when a Flutter app (android, ios, macos, linux, windows or web) needs a
  sembast NoSQL database with one factory that works everywhere, with
  tekartik_app_flutter_sembast: the package:tekartik_app_flutter_sembast/sembast.dart
  import, getDatabaseFactory(packageName:, rootPath:), databaseFactoryMemory
  for unit tests, the setup/sembast_sqflite.dart databaseFactorySqflite and
  setup/sembast_sqflite_ffi.dart databaseFactorySqfliteFfi variants, the
  deprecated initDatabaseFactory, and the re-exported sembast API (Database,
  DatabaseFactory, StoreRef, stringMapStoreFactory, intMapStoreFactory,
  RecordRef, Finder, Filter, SortOrder, transaction).
---

# Cross platform sembast database for Flutter (tekartik_app_flutter_sembast)

This package hides the platform choice behind a single
`DatabaseFactory`: `sembast_sqflite` (sqlite) on android, ios, macos, linux
and windows, `sembast_web` (IndexedDB) on the web. App code only uses the
plain `sembast` API.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_sembast:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_sembast
      version: '>=0.1.0'
  ```
* Main library: `package:tekartik_app_flutter_sembast/sembast.dart`. It
  re-exports the whole `package:sembast/sembast.dart` API (`Database`,
  `DatabaseFactory`, `StoreRef`, `stringMapStoreFactory`,
  `intMapStoreFactory`, `RecordRef`, `RecordSnapshot`, `Finder`, `Filter`,
  `SortOrder`, `Transaction`, `DatabaseException`, `SembastCodec`, ...), so a
  single import is enough. Never import anything under `lib/src/`.
* `DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath})`
  is the entry point, resolved by conditional import:
  * web (`dart.library.js_interop`): `databaseFactoryWeb` from `sembast_web`,
    an IndexedDB database; `packageName` and `rootPath` are ignored.
  * io (`dart.library.io`): `sembast_sqflite` on top of
    `tekartik_app_flutter_sqflite`'s factory (sqlite through ffi, registered
    by its `sqflite_ffi` plugin dependency).
  * any other target: a stub that throws `UnimplementedError`.
* `packageName` / `rootPath` matter on linux and windows only: without them
  the database lands in a `.`-named folder. Pass a reverse domain
  `packageName` (`'com.example.myapp'`) so files go to
  `<userAppDataPath>/<packageName>/databases`, or an explicit `rootPath` for a
  fully controlled location (handy in tests:
  `'.dart_tool/my_app/db'`). On android/ios/macos both are ignored.
* Call `WidgetsFlutterBinding.ensureInitialized()` before opening a database
  in `main()`, open the database **once** for the whole app and keep it open
  (the factory returns the same single instance for a given path); do not
  open/close per screen. `await db.close()` only when the app tears down or
  in tests.
* Unit tests: use the exported `databaseFactoryMemory` (sembast's
  `databaseFactoryMemoryFs`, a file-system-like in-memory factory, so
  `openDatabase('test.db')` works and data survives a close/reopen within the
  test). It needs no binding, no plugin and no disk.
* Two explicit escape hatches when you do not want the automatic choice:
  * `package:tekartik_app_flutter_sembast/setup/sembast_sqflite.dart` ->
    `databaseFactorySqflite`, built on the native `sqflite` plugin
    (android/ios/macos). Add `sqflite` to your own `dependencies` to use it.
  * `package:tekartik_app_flutter_sembast/setup/sembast_sqflite_ffi.dart` ->
    `databaseFactorySqfliteFfi`, built on `sqflite_common_ffi` (desktop and
    the Dart VM); call `sqfliteFfiInit()` first outside Flutter.
  * `setup/sembast_flutter.dart`'s `initDatabaseFactory({packageName})` is
    deprecated - use `getDatabaseFactory()`.
* On windows during development (`flutter test`, dart VM) call
  `sqfliteWindowsFfiInit()` from
  `package:tekartik_app_flutter_sqflite/sqflite.dart` before using the
  factory, so the sqlite3 dll is found.
* Web caveats: IndexedDB is asynchronous and per origin, there is no file on
  disk, the database name is a key, and clearing site data wipes it. Keep the
  data model identical across platforms; anything sqlite specific (raw SQL) is
  not available through sembast anyway.
* Anti-patterns: calling `getDatabaseFactory()` on every access (call it once,
  store the factory or the `Database`), hardcoding a file path instead of
  `packageName`/`rootPath`, importing `sembast_web` / `sembast_sqflite`
  directly in app code, and using `databaseFactoryMemory` in production code.

## Examples

### Open once at startup

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

late final Database appDatabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// packageName is only used on linux/windows, ignored elsewhere.
  var factory = getDatabaseFactory(packageName: 'com.example.myapp');
  appDatabase = await factory.openDatabase('myapp.db', version: 1);

  var store = StoreRef<String, String>.main();
  await store.record('greeting').put(appDatabase, 'hello');
  print(await store.record('greeting').get(appDatabase));
}
```

### A store based repository

```dart
import 'package:tekartik_app_flutter_sembast/sembast.dart';

class NoteRepository {
  final Database db;

  /// Typed store: int keys, map values.
  final store = intMapStoreFactory.store('note');

  NoteRepository(this.db);

  Future<int> add(String title) =>
      store.add(db, <String, Object?>{'title': title, 'done': false});

  Future<void> setDone(int key, bool done) async {
    await store.record(key).update(db, <String, Object?>{'done': done});
  }

  /// Pending notes, most recent first.
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> pending() {
    var finder = Finder(
      filter: Filter.equals('done', false),
      sortOrders: [SortOrder(Field.key, false)],
    );
    return store.find(db, finder: finder);
  }

  /// Live updates for a StreamBuilder.
  Stream<List<RecordSnapshot<int, Map<String, Object?>>>> onPending() {
    return store.query(finder: Finder(filter: Filter.equals('done', false)))
        .onSnapshots(db);
  }

  /// Group writes in a transaction.
  Future<void> addAll(List<String> titles) async {
    await db.transaction((txn) async {
      for (var title in titles) {
        await store.add(txn, <String, Object?>{'title': title, 'done': false});
      }
    });
  }
}
```

### Unit test with the in-memory factory

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

void main() {
  test('open/close', () async {
    /// In memory implementation, no plugin and no disk needed.
    var factory = databaseFactoryMemory;
    var store = StoreRef<String, String>.main();

    var db = await factory.openDatabase('test.db');
    await store.record('k').put(db, 'v');
    await db.close();

    db = await factory.openDatabase('test.db');
    expect(await store.record('k').get(db), 'v');
    await db.close();
    await factory.deleteDatabase('test.db');
  });
}
```

### Desktop / dart VM test on a controlled path

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart'
    show sqfliteWindowsFfiInit;

void main() {
  /// Initializes sqflite ffi (finds the sqlite3 dll on windows). Safe on any
  /// dart VM/desktop target, throws UnimplementedError on the web.
  sqfliteWindowsFfiInit();

  /// rootPath keeps the files inside the project on linux/windows.
  var factory = getDatabaseFactory(
    rootPath: '.dart_tool/my_app/db',
    packageName: 'com.example.myapp',
  );

  test('sqlite backed factory', () async {
    await factory.deleteDatabase('test.db');
    var db = await factory.openDatabase('test.db');
    var store = stringMapStoreFactory.store('settings');
    await store.record('theme').put(db, <String, Object?>{'dark': true});
    expect(await store.record('theme').get(db), <String, Object?>{'dark': true});
    await db.close();
  });
}
```
