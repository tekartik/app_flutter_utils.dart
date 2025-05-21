import 'package:fs_shim/fs_memory.dart';
import 'package:tekartik_app_flutter_fs/src/fs.dart';

import 'src/fs.dart' as src;

export 'package:fs_shim/fs_shim.dart';

/// The FileSystem to use for your flutter application.
///
/// For mobile, it uses the native IO implementation, on the web,
/// it uses fs_shim on top of indexed db.
///
/// For testing you can use an in memory implementation for idb_shim.
FileSystem get fs => src.fs;

/// The memory file system to use for your flutter application.
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
  /// On the web, it is the data root directory
  ///
  /// [packageName] only used on linux and windows for now
  Future<Directory> getApplicationDocumentsDirectory({
    String? packageName,
  }) async {
    if (this == fs) {
      return src.getApplicationDocumentsDirectory(packageName: packageName);
    }
    return getFsApplicationDocumentsDirectory(this);
  }
}
