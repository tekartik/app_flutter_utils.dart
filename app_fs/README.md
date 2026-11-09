# tekartik_app_flutter_fs

One file system for a Flutter app on every platform: `dart:io` on mobile and
desktop, IndexedDB on the web, behind the
[fs_shim](https://pub.dev/packages/fs_shim) API (`FileSystem`, `File`,
`Directory`), plus the app documents and support directories.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_fs:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_fs
```

```dart
import 'package:tekartik_app_flutter_fs/fs.dart';

Future<String> writeAndRead() async {
  // Create it: the directory may not exist yet.
  var dir = await fs.getApplicationDocumentsDirectory(
    packageName: 'com.example.myapp',
  );
  await dir.create(recursive: true);
  var file = fs.file(fs.path.join(dir.path, 'hello.txt'));
  await file.writeAsString('hello');
  return await file.readAsString();
}
```

Complete app in [example/main.dart](example/main.dart).
`package:tekartik_app_flutter_fs/fs.dart` exports the fs_shim API.

## Platforms

| Platform | `fs` | `getApplicationDocumentsDirectory(packageName:)` | `getApplicationSupportDirectory()` |
|---|---|---|---|
| Android, iOS, macOS | `dart:io` | path_provider documents directory | path_provider support directory |
| Linux, Windows | `dart:io` | `<userAppDataPath>/<packageName>/data` (`~/.config/...`, `%APPDATA%\...`) | path_provider support directory |
| Web | IndexedDB (per origin) | `/data` | `/support` |

`userAppDataPath` comes from process_run (`TEKARTIK_PROCESS_RUN_USER_APP_DATA_PATH`
overrides it). On any other `FileSystem` (`fsMemory` for tests), the two
methods return its `/data` and `/support` directories.

## Common pitfalls

- `packageName` only counts on Linux and Windows, but there it is the
  folder: without it every app shares `<userAppDataPath>/data`.
- Create the directory (`create(recursive: true)`) before writing in it.
- Use `fs.file(...)` / `fs.directory(...)` and `fs.path.join`: `dart:io` or
  hardcoded separators break the web.
- Tests: pass a `FileSystem` to your code and use `fsMemory` (in memory, every
  platform); under `flutter test` `fs` is the real disk and the extension
  calls path_provider (no plugin there), except for the documents directory
  on Linux and Windows.
- Web data lives in the browser and goes with the site data.

Agent skill:
[tekartik-app-flutter-fs-setup](skills/tekartik-app-flutter-fs-setup/SKILL.md).
