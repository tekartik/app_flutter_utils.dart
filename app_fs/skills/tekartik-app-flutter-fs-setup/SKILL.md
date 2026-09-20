---
name: tekartik-app-flutter-fs-setup
description: >-
  Use when reading or writing files from a Flutter app on every platform
  (android, ios, linux, macos, windows and web) with tekartik_app_flutter_fs:
  the package:tekartik_app_flutter_fs/fs.dart import, the global fs FileSystem
  getter, fsMemory, the AppFileSystem extension methods
  getApplicationDocumentsDirectory(packageName:) and
  getApplicationSupportDirectory(), fs.file / fs.directory / fs.path, the
  fs_shim File, Directory, FileSystemEntity, FileMode, FileStat and
  FileSystemException types, and how to inject an in-memory file system in
  tests instead of dart:io.
---

# Cross platform file system for a Flutter app (tekartik_app_flutter_fs)

This package gives a Flutter app one `FileSystem` object that works on every
target: `dart:io` on mobile and desktop, IndexedDB (through `fs_shim`'s idb
implementation) on the web. App code uses the `fs_shim` API and never
imports `dart:io`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_fs:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_fs
      version: '>=0.1.0'
  ```
* One public library: `package:tekartik_app_flutter_fs/fs.dart`. It
  re-exports `package:fs_shim/fs_shim.dart` (`FileSystem`, `File`,
  `Directory`, `Link`, `FileSystemEntity`, `FileMode`, `FileStat`,
  `FileSystemEntityType`, `FileSystemException`, `fileSystemIo`,
  `fileSystemMemory`, `fileSystemWeb`, `fileSystemDefault`) and adds
  `FileSystem get fs`, the `FileSystem fsMemory` field and the
  `AppFileSystem` extension. Never import anything under `lib/src/`.
* `fs` is resolved by conditional import: `dart:io` builds get
  `fileSystemIo`, `dart:js_interop` (web) builds get an IndexedDB backed file
  system (`newFileSystemIdb(idbFactoryNative)`), any other target gets a stub
  that throws `UnimplementedError`. Importing is safe everywhere.
* Always go through the file system object: `fs.file(path)`,
  `fs.directory(path)`, `fs.link(path)`, `fs.type(path)`, `fs.isFile(path)`,
  `fs.isDirectory(path)`, `fs.path` (a `package:path` `Context`),
  `fs.currentDirectory`, `fs.supportsLink`, `fs.supportsRandomAccess`. Do not
  use the bare `File('...')` / `Directory('...')` constructors from `fs_shim`:
  they target `fileSystemDefault`, not `fs`.
* Get a writable location with the `AppFileSystem` extension, never a
  hardcoded path:
  * `await fs.getApplicationDocumentsDirectory(packageName: 'x.example.com')`
    - user data. On ios/android it delegates to `path_provider`; on linux and
    windows it is `<userAppDataPath>/<packageName>/data`, so `packageName` is
    required there; on the web it is the `/data` root of the idb file system.
  * `await fs.getApplicationSupportDirectory()` - non user visible app files
    (`path_provider` on native, `/support` on the web).
  * Called on any *other* `FileSystem` (for example `fsMemory`), both return
    the plain `/data` and `/support` directories of that file system.
* `File`: `create(recursive:)`, `writeAsString(...)`, `writeAsBytes(...)`,
  `readAsString()`, `readAsBytes()`, `openRead()`, `openWrite()`, `copy()`,
  `rename()`, `delete()`, `exists()`, `stat()`, `parent`, `absolute`.
  `Directory`: `create(recursive:)`, `list(recursive:, followLinks:)` (a
  `Stream<FileSystemEntity>`), `delete(recursive:)`, `rename()`, `exists()`.
  Create the parent directory (`create(recursive: true)`) before writing, or
  catch `FileSystemException`.
* `fsMemory` is a ready-to-use in-memory `FileSystem` exported by this
  package; use it for tests and for scratch data. It is a mutable top-level
  field, so a test can replace it. `newFileSystemMemory([name])` is not
  re-exported here: import `package:fs_shim/fs_memory.dart` if you need a
  fresh, independent instance.
* Design for testability: pass a `FileSystem` into your classes (defaulting
  to `fs`) instead of referencing the global everywhere. Unit tests
  (`flutter test`, no device) then run against `fsMemory`; `fs` itself throws
  on an unsupported target.
* Web caveats: the idb file system is asynchronous and sandboxed per origin,
  there is no real path on disk, `supportsLink` is limited, and the data is
  wiped when the browser clears site data. Keep paths relative to the
  directory returned by the extension methods.

## Examples

### Write and read a file in the app documents directory

```dart
import 'package:tekartik_app_flutter_fs/fs.dart';

Future<File> appFile(String name) async {
  var dir = await fs.getApplicationDocumentsDirectory(
    packageName: 'test1.tekartik.com',
  );
  await dir.create(recursive: true);
  return fs.file(fs.path.join(dir.path, name));
}

Future<void> main() async {
  var file = await appFile('notes.txt');
  await file.writeAsString('hello');
  print(await file.readAsString());
  print('exists: ${await file.exists()}, size: ${(await file.stat()).size}');
  await file.delete();
}
```

### List and clean a directory

```dart
import 'package:tekartik_app_flutter_fs/fs.dart';

Future<void> dumpAndClear(FileSystem fileSystem) async {
  var dir = await fileSystem.getApplicationSupportDirectory();
  if (await dir.exists()) {
    await for (var entity in dir.list(recursive: true)) {
      var type = await fileSystem.type(entity.path);
      print('$type ${entity.path}');
    }
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);
}
```

### Injectable storage class, testable with fsMemory

```dart
import 'dart:convert';

import 'package:tekartik_app_flutter_fs/fs.dart';

class NoteStorage {
  final FileSystem fileSystem;

  /// Defaults to the platform file system, tests pass fsMemory.
  NoteStorage({FileSystem? fileSystem}) : fileSystem = fileSystem ?? fs;

  Future<File> _file() async {
    var dir = await fileSystem.getApplicationDocumentsDirectory(
      packageName: 'com.example.notes',
    );
    await dir.create(recursive: true);
    return fileSystem.file(fileSystem.path.join(dir.path, 'notes.json'));
  }

  Future<List<String>> load() async {
    var file = await _file();
    if (!await file.exists()) {
      return <String>[];
    }
    return (jsonDecode(await file.readAsString()) as List).cast<String>();
  }

  Future<void> save(List<String> notes) async {
    var file = await _file();
    await file.writeAsString(jsonEncode(notes));
  }
}

Future<void> useInTest() async {
  var storage = NoteStorage(fileSystem: fsMemory);
  await storage.save(['a', 'b']);
  print(await storage.load());
}
```

### Streaming a large file

```dart
import 'dart:convert';

import 'package:tekartik_app_flutter_fs/fs.dart';

/// openRead() gives a Stream<Uint8List>, openWrite() a StreamSink<List<int>>.
Future<void> copyLines(File source, File destination) async {
  var sink = destination.openWrite(mode: FileMode.write);
  try {
    var lines = utf8.decoder
        .bind(source.openRead())
        .transform(const LineSplitter());
    await for (var line in lines) {
      sink.add(utf8.encode('${line.trim()}\n'));
    }
    await sink.flush();
  } finally {
    await sink.close();
  }
}
```

## Common mistakes

* Using the bare `File('path')` / `Directory('path')` constructors, or
  `dart:io`, instead of `fs.file(path)` / `fs.directory(path)`: they bypass
  the platform selection and break on the web.
* Omitting `packageName` in `getApplicationDocumentsDirectory`: it is what
  builds the linux/windows path.
* Hardcoding `/` or `\` separators instead of `fs.path.join(...)`.
* Writing a file without creating its parent directory first.
* Reading the global `fs` inside library code that must be unit testable -
  inject a `FileSystem` and pass `fsMemory` in tests.
