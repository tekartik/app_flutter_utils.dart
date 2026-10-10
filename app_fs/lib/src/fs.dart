import 'package:fs_shim/fs.dart';

export 'fs_stub.dart'
    if (dart.library.js_interop) 'fs_web.dart'
    if (dart.library.io) 'fs_io.dart';

/// Data directory
const dataDirectory = 'data';

/// Support directory
const supportDirectory = 'support';

/// The directory [name] at the root of [fs], `/data`: in the path style of
/// [fs], not of the platform, a memory or indexed db file system using `/` on
/// Windows too.
Directory _rootDirectory(FileSystem fs, String name) =>
    fs.directory(fs.path.join(fs.path.separator, name));

/// Get the application file system
Directory getFsApplicationDocumentsDirectory(FileSystem fs) {
  return _rootDirectory(fs, dataDirectory);
}

/// Get the application support directory
Directory getFsApplicationSupportDirectory(FileSystem fs) {
  return _rootDirectory(fs, supportDirectory);
}
