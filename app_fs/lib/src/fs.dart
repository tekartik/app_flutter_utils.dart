import 'package:fs_shim/fs.dart';
import 'package:path/path.dart';

export 'fs_stub.dart'
    if (dart.library.html) 'fs_web.dart'
    if (dart.library.io) 'fs_io.dart';

const dataDirectory = 'data';
final String dataDirectoryPath = '${context.separator}$dataDirectory';

Directory getFsApplicationDocumentsDirectory(FileSystem fs) {
  return fs.directory(dataDirectoryPath);
}
