# tekartik_app_flutter_idb

One IndexedDB style database factory for a Flutter app on every platform:
[idb_shim](https://pub.dev/packages/idb_shim) on SQLite
([idb_sqflite](https://pub.dev/packages/idb_sqflite) over
[tekartik_app_flutter_sqflite](../app_sqflite/README.md)) on Android, iOS,
macOS, Linux and Windows, the browser IndexedDB on the web.

Two APIs on the same factory:

- `sdb.dart`: `SdbFactory`, the typed, simpler API of idb_shim (stores and
  indexes declared once, `put`/`get`/`findRecords`). **Use it for new code.**
- `idb.dart`: `IdbFactory`, the raw IndexedDB API (transactions, object
  stores, cursors).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_idb:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_idb
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';

final noteStore = SdbStoreRef<int, String>('note');

Future<SdbDatabase> openNotes() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once: packageName is the databases folder on Linux and Windows.
  var factory = getSdbFactory(packageName: 'com.example.myapp');
  return await factory.openDatabase(
    'notes.db',
    options: SdbOpenDatabaseOptions(
      version: 1,
      onVersionChange: (event) {
        if (event.oldVersion < 1) {
          event.db.createStore(noteStore);
        }
      },
    ),
  );
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | Storage |
|---|---|
| Android, iOS, macOS | SQLite (sqflite_common_ffi, bundled), in the sqflite plugin databases folder |
| Linux, Windows | `getSdbFactory` / `getIdbFactory(packageName:)`: `<userAppDataPath>/<packageName>/databases` (`~/.config/...`, `%APPDATA%\...`) |
| Web | the browser IndexedDB of the origin |
| Unit tests | `sdbFactoryMemory` / `idbFactoryMemory` (or `newSdbFactoryMemory()` / `newIdbFactoryMemory()`) |

## Common pitfalls

- On Linux and Windows always use `getSdbFactory` / `getIdbFactory` with a
  `packageName`: the `sdbFactory` / `idbFactory` getters keep the ffi default
  folder (`.dart_tool/sqflite_common_ffi/databases` of the current
  directory), and no `packageName` means `<userAppDataPath>/databases`,
  shared by every app.
- On Linux and Windows the databases folder is the one of a single shared
  sqflite factory: call it once per app. A later `getIdbFactory` with
  another package name, a `getDatabaseFactory(...)` of
  tekartik_app_flutter_sembast or tekartik_app_flutter_sqflite moves the
  databases of every factory returned before (the last call wins).
- `packageName` is ignored on Android, iOS, macOS and the web.
- In an `onVersionChange` / `onUpgradeNeeded` callback, await nothing but
  the database being upgraded (the transaction would end).

Agent skills:
[tekartik-app-flutter-idb-sdb](skills/tekartik-app-flutter-idb-sdb/SKILL.md),
[tekartik-app-flutter-idb-setup](skills/tekartik-app-flutter-idb-setup/SKILL.md).
