import 'package:fs_shim/fs_memory.dart';
import 'package:tekartik_app_flutter_fs/src/fs.dart';

import 'src/fs.dart' as src;

export 'package:fs_shim/fs_shim.dart';

/// The FileSystem to use for your flutter application.
///
/// On mobile and desktop, it uses the native IO implementation (`dart:io`),
/// on the web, it uses fs_shim on top of indexed db.
///
/// For testing, pass [fsMemory] (in memory) to your code instead.
FileSystem get fs => src.fs;

/// An in memory file system (fs_shim), for tests and scratch data.
FileSystem fsMemory = newFileSystemMemory();

/// path provider file system extension
extension AppFileSystem on FileSystem {
  /// Path to a directory where the application may place data that is
  /// user-generated, or that cannot otherwise be recreated by your application.
  ///
  /// On iOS, this uses the `NSDocumentDirectory` API. Consider using
  /// [getApplicationSupportDirectory] instead if the data is not user-generated.
  ///
  /// On Android, this uses the `getDataDirectory` API on the context. Consider
  /// using [getExternalStorageDirectory] instead if data is intended to be visible
  /// to the user.
  ///
  /// On Linux and Windows, it is `<userAppDataPath>/<packageName>/data`
  /// (process_run `userAppDataPath`: `~/.config`, `%APPDATA%`), shared by
  /// every app without [packageName].
  ///
  /// On the web, it is the data root directory (`/data`), as on any other
  /// file system than [fs] (`fsMemory`).
  ///
  /// [packageName] only used on linux and windows for now. The directory may
  /// not exist yet: create it before writing.
  Future<Directory> getApplicationDocumentsDirectory({
    String? packageName,
  }) async {
    if (this == fs) {
      return src.getApplicationDocumentsDirectory(packageName: packageName);
    }

    return getFsApplicationDocumentsDirectory(this);
  }

  /// Path to a directory where the application may place application
  /// support files, i.e. files that are not user-generated and that your
  /// app does not want exposed to the user.
  ///
  /// On iOS and macOS, this uses the `NSApplicationSupportDirectory` API.
  ///
  /// On Android, this uses the Flutter engine's `PathUtils.getFilesDir` API.
  ///
  /// On the web, it is a dedicated directory within the data root.
  Future<Directory> getApplicationSupportDirectory() async {
    if (this == fs) {
      return src.getApplicationSupportDirectory();
    }

    return getFsApplicationSupportDirectory(this);
  }
}
