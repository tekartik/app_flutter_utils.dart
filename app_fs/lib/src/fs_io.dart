import 'dart:io' as io;

import 'package:fs_shim/fs.dart';
import 'package:fs_shim/fs_io.dart' show fileSystemIo, wrapIoDirectory;
import 'package:path_provider/path_provider.dart' as plugin;
import 'package:process_run/shell_run.dart';

/// File system
FileSystem get fs => fileSystemIo;

///
Future<Directory> getApplicationDocumentsDirectory({
  String? packageName,
}) async {
  if (io.Platform.isLinux || io.Platform.isWindows) {
    var dataPath = fs.path.join(userAppDataPath, packageName, 'data');
    return fs.directory(dataPath);
  } else {
    var directory = await plugin.getApplicationDocumentsDirectory();
    return wrapIoDirectory(directory);
  }
}
