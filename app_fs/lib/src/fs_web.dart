import 'package:fs_shim/fs_idb.dart';
import 'package:idb_shim/idb_client_native.dart';
import 'package:tekartik_app_flutter_fs/src/fs.dart';

FileSystem? _fs;

/// Get the application file system
FileSystem get fs => _fs ??= newFileSystemIdb(idbFactoryNative);

/// Package name ignored for indexed_db, we are already in a sandbox
Future<Directory> getApplicationDocumentsDirectory({
  String? packageName,
}) async {
  return getFsApplicationDocumentsDirectory(fs);
}
