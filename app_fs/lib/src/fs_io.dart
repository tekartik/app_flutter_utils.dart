import 'dart:io';

import 'package:fs_shim/fs.dart';
import 'package:fs_shim/fs_io.dart' show fileSystemIo, wrapIoDirectory;
import 'package:path_provider/path_provider.dart' as plugin;
import 'package:process_run/shell_run.dart';

FileSystem get fs => fileSystemIo;

Future<Directory> getApplicationDocumentsDirectory({String? packageName}) async {
  if (Platform.isLinux || Platform.isWindows) {
    var dataPath = fs.path.join(userAppDataPath, packageName, 'data');
    return fs.directory(dataPath);
  } else {
    var directory = await plugin.getApplicationDocumentsDirectory();
    return directory == null ? null : wrapIoDirectory(directory);
  }
}
