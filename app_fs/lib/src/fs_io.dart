import 'package:fs_shim/fs.dart';
import 'package:fs_shim/fs_io.dart' show fileSystemIo, wrapIoDirectory;
import 'package:path_provider/path_provider.dart' as plugin;

FileSystem get fs => fileSystemIo;

Future<Directory> getApplicationDocumentsDirectory() async {
  var directory = await plugin.getApplicationDocumentsDirectory();
  return directory == null ? null : wrapIoDirectory(directory);
}
