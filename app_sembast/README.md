# tekartik_app_flutter_sembast

One [sembast](https://pub.dev/packages/sembast) `DatabaseFactory` for a
Flutter app on every platform: sembast on SQLite
([sembast_sqflite](https://pub.dev/packages/sembast_sqflite) over
[tekartik_app_flutter_sqflite](../app_sqflite/README.md), ffi) on Android,
iOS, macOS, Linux and Windows,
[sembast_web](https://pub.dev/packages/sembast_web) (IndexedDB) on the web.
It re-exports the sembast API.

For new local database code prefer the sdb API of
[tekartik_app_flutter_idb](../app_idb/README.md) (`sdb.dart`): this package
is for apps already on sembast.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_sembast:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_sembast
```

Get the factory once, open the database once and keep it open:

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

late final Database appDatabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // packageName: the databases folder on Linux and Windows.
  var factory = getDatabaseFactory(packageName: 'com.example.myapp');
  appDatabase = await factory.openDatabase('app.db');
  var store = StoreRef<String, String>.main();
  await store.record('greeting').put(appDatabase, 'hello');
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | Storage |
|---|---|
| Android, iOS, macOS | SQLite (sqflite_common_ffi, bundled), in the sqflite plugin databases folder |
| Linux, Windows | `packageName:` `<userAppDataPath>/<packageName>/databases`; `rootPath:` that folder instead |
| Web | IndexedDB of the origin (`databaseFactoryWeb`), parameters ignored |
| Unit tests | `databaseFactoryMemory` (no disk, no plugin); `rootPath:` is honored under `flutter test` on every platform |

## Common pitfalls

- Call `getDatabaseFactory` once and keep the factory (or the database):
  each call builds a new sembast factory, and two of them opening the same
  file are two databases with their own cache (a write through one is seen
  by the other only on its next write).
- On Linux and Windows the databases folder is the one of a single shared
  sqflite factory: a later `getDatabaseFactory` with another `packageName`
  or `rootPath` (or none: `<userAppDataPath>/databases`, shared by every
  app), or an app_idb / app_sqflite one, moves the databases of every
  factory returned before (the last call wins).
- `packageName` and `rootPath` are ignored on Android, iOS, macOS and the
  web (`rootPath` counts under `flutter test`).
- `setup/sembast_sqflite.dart` (`databaseFactorySqflite`, the sqflite
  plugin) needs `sqflite` in your own dependencies.

## Samples

[demo_sembast](https://github.com/alextekartik/flutter_app_example/tree/master/demo_sembast)
([online](https://alextekartik.github.io/flutter_app_example/demo_sembast/))
and
[notepad_sembast](https://github.com/alextekartik/flutter_app_example/tree/master/notepad_sembast)
([online](https://alextekartik.github.io/flutter_app_example/notepad_sembast/)).

Agent skill:
[tekartik-app-flutter-sembast-setup](skills/tekartik-app-flutter-sembast-setup/SKILL.md).
