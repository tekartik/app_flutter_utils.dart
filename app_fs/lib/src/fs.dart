import 'package:fs_shim/fs.dart';
import 'package:path/path.dart';

export 'fs_stub.dart'
    if (dart.library.js_interop) 'fs_web.dart'
    if (dart.library.io) 'fs_io.dart';

/// Data directory
const dataDirectory = 'data';

/// Data directory path
final String dataDirectoryPath = '${context.separator}$dataDirectory';

/// Get the application file system
Directory getFsApplicationDocumentsDirectory(FileSystem fs) {
  return fs.directory(dataDirectoryPath);
}
