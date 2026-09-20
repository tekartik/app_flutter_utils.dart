---
name: tekartik-app-flutter-sqflite-setup
description: >-
  Use when a Flutter app needs one sqflite DatabaseFactory that works on
  android, ios, macos, linux, windows and the web, with
  tekartik_app_flutter_sqflite: the package:tekartik_app_flutter_sqflite/sqflite.dart
  import, the databaseFactory getter, getDatabaseFactory(packageName:,
  rootPath:), sqfliteWindowsFfiInit(), the deprecated initDatabaseFactory, and
  the re-exported sqflite_common sqlite_api (Database, DatabaseFactory,
  OpenDatabaseOptions, openDatabase, getDatabasesPath, Batch, Transaction,
  ConflictAlgorithm, DatabaseException, inMemoryDatabasePath).
---

# Cross platform sqflite factory for Flutter (tekartik_app_flutter_sqflite)

A thin initialization layer over sqflite: it picks the right implementation
per platform (ffi on android/ios/macos/linux/windows, ffi web on the browser)
and computes a sane database directory on desktop, then hands back a plain
`DatabaseFactory`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_sqflite:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_sqflite
      version: '>=0.2.0'
  ```
* One public library: `package:tekartik_app_flutter_sqflite/sqflite.dart`. It
  re-exports `package:sqflite_common/sqlite_api.dart`, so `Database`,
  `DatabaseFactory`, `OpenDatabaseOptions`, `Transaction`, `Batch`,
  `ConflictAlgorithm`, `DatabaseException`, `inMemoryDatabasePath` come with
  it and you do not add `sqflite` to your pubspec. Never import anything
  under `lib/src/`.
* Everything goes through a factory - there is no top level
  `openDatabase(...)` here:
  * `databaseFactory` - the default factory. Resolved by conditional import:
    `sqflite_common_ffi`'s `databaseFactoryFfi` on io targets (the package
    depends on the `sqflite_ffi` Flutter plugin, which registers ffi at
    startup, so no extra platform setup), `databaseFactoryFfiWeb` on the web,
    a stub that throws `UnimplementedError` elsewhere.
  * `getDatabaseFactory({String? packageName, String? rootPath})` - same
    factory, but on **linux and windows** it also sets the databases path to
    `rootPath`, or to `<userAppDataPath>/<packageName>/databases` (created if
    missing). Without either, desktop databases land in a `.` folder, so
    always pass a reverse domain `packageName` (or an explicit `rootPath` in
    tests). Both are ignored on android/ios/macos/web.
* Open with options instead of raw arguments:
  `factory.openDatabase(path, options: OpenDatabaseOptions(version: 1,
  onCreate: ..., onUpgrade: ..., onConfigure: ...))`. Databases are
  `singleInstance` by default, so open once at startup and keep the
  `Database` around; `WidgetsFlutterBinding.ensureInitialized()` must run
  first in `main()`.
* Build the path with `factory.getDatabasesPath()` + `package:path`'s `join`,
  never with a hardcoded separator, and never with `dart:io` (it breaks the
  web build). `inMemoryDatabasePath` gives a throwaway database.
* `sqfliteWindowsFfiInit()` initializes sqflite ffi (finding the sqlite3 dll
  on windows); call it at the start of a dart VM/desktop test or tool before
  any factory use. It throws `UnimplementedError` on the web.
* Web target: the ffi web implementation needs the sqlite3 wasm assets in
  `web/`; install them once with
  ```bash
  dart run sqflite_common_ffi_web:setup
  ```
  Storage is per origin (IndexedDB backed) and wiped when site data is
  cleared.
* `initDatabaseFactory(packageName)` is deprecated (it returns a `Future`);
  use `getDatabaseFactory(packageName: ...)`.
* Tests: `flutter test` runs on the dart VM, so call
  `sqflite_ffi.sqfliteFfiInit()` (from `package:sqflite_common_ffi/sqflite_ffi.dart`)
  in `main()` and point the factory at a project local `rootPath`; delete the
  database first (`factory.deleteDatabase(path)`) to make tests repeatable.
* Anti-patterns: importing `sqflite` / `sqflite_common_ffi` directly in app
  code, calling `getDatabaseFactory()` on every query, reopening the database
  per screen, and forgetting `packageName` on desktop.

## Examples

### Open a database at startup

```dart
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

late final Database appDatabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// packageName is only used on linux/windows, ignored elsewhere.
  var factory = getDatabaseFactory(packageName: 'com.example.myapp');
  var path = join(await factory.getDatabasesPath(), 'myapp.db');

  appDatabase = await factory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE Note (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  done INTEGER NOT NULL DEFAULT 0
)''');
      },
    ),
  );
}
```

### CRUD, transaction and batch

```dart
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

class NoteRepository {
  final Database db;

  NoteRepository(this.db);

  Future<int> insert(String title) => db.insert('Note', <String, Object?>{
    'title': title,
    'done': 0,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Map<String, Object?>>> pending() => db.query(
    'Note',
    columns: ['id', 'title'],
    where: 'done = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  Future<void> setDone(int id, bool done) async {
    await db.update(
      'Note',
      <String, Object?>{'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// One round trip for many writes.
  Future<void> insertAll(List<String> titles) async {
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var title in titles) {
        batch.insert('Note', <String, Object?>{'title': title, 'done': 0});
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> count() async {
    var result = await db.rawQuery('SELECT COUNT(*) AS n FROM Note');
    return (result.first['n'] as int?) ?? 0;
  }
}
```

### Test on the dart VM

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

void main() {
  /// Needed on the dart VM (and on windows to find the sqlite3 dll).
  sqflite_ffi.sqfliteFfiInit();

  test('open and query', () async {
    var factory = getDatabaseFactory(rootPath: '.dart_tool/my_app/databases');
    var path = 'test.db';
    await factory.deleteDatabase(path);

    var db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) =>
            db.execute('CREATE TABLE Pref (id TEXT PRIMARY KEY, value INTEGER)'),
      ),
    );
    await db.insert('Pref', <String, Object?>{'id': 'count', 'value': 1});
    expect(await db.query('Pref'), [
      <String, Object?>{'id': 'count', 'value': 1},
    ]);
    await db.close();
  });

  test('in memory', () async {
    var db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
    await db.close();
  });
}
```
