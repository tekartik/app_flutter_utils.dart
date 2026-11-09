# tekartik_app_flutter_sqflite

One sqflite `DatabaseFactory` for a Flutter app on every platform, with its
databases folder set: the ffi implementation
([sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi), SQLite
bundled with the app) on Android, iOS, macOS, Linux and Windows, the ffi web
one ([sqflite_common_ffi_web](https://pub.dev/packages/sqflite_common_ffi_web),
SQLite in WebAssembly over IndexedDB) on the web. It exports the
`sqflite_common` API (`Database`, `OpenDatabaseOptions`, `Batch`...).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_sqflite:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_sqflite
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

Future<Database> openAppDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once: packageName is the databases folder on Linux and Windows.
  var factory = getDatabaseFactory(packageName: 'com.example.myapp');
  return await factory.openDatabase(
    'app.db', // relative: in the databases folder
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Pref (id TEXT PRIMARY KEY, value INTEGER NOT NULL)',
        );
      },
    ),
  );
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | Databases folder (relative paths) |
|---|---|
| Android | `/data/user/0/<application id>/databases`, the sqflite plugin folder (set once, before the first call) |
| iOS, macOS | the app Documents directory, the sqflite plugin folder |
| Linux, Windows | `getDatabaseFactory(packageName:)`: `<userAppDataPath>/<packageName>/databases` (`~/.config/...`, `%APPDATA%\...`, created); `rootPath:` that folder instead |
| Web | IndexedDB of the origin; run `dart run sqflite_common_ffi_web:setup` once to add `sqlite3.wasm` and the worker to `web/` |
| `flutter test` | `.dart_tool/sqflite_common_ffi/databases` of the current directory; `rootPath:` honored on every platform |

Android, iOS and macOS use the folders of the sqflite plugin, so an app
moving from `sqflite` finds its databases.

## Common pitfalls

- On Linux and Windows, `databaseFactory` alone keeps the ffi default
  (`.dart_tool/sqflite_common_ffi/databases` of the current directory): call
  `getDatabaseFactory(packageName:)` first.
- `getDatabaseFactory` on Linux and Windows sets the folder of one shared
  factory (`databaseFactory` is the same object): call it once, the last
  call wins for every factory it returned. `packageName` and `rootPath` are
  ignored on Android, iOS, macOS and the web (`rootPath` counts under
  `flutter test`).
- `sqfliteWindowsFfiInit()` throws on the web: guard it with `!kIsWeb`.
- The factory is `databaseFactoryFfi` of sqflite_common_ffi, not the
  `sqfliteDatabaseFactoryFfi` that the `sqflite_ffi` plugin registers for
  sqflite's global `openDatabase`: do not mix both on the same file, and
  pass a full path to a background isolate.

Agent skill:
[tekartik-app-flutter-sqflite-setup](skills/tekartik-app-flutter-sqflite-setup/SKILL.md).
