import 'package:fs_shim/fs_idb.dart';
import 'package:idb_shim/idb_client_native.dart';
import 'package:tekartik_app_flutter_fs/src/fs.dart';

FileSystem _fs;

FileSystem get fs => _fs ??= newFileSystemIdb(idbFactoryNative);

Future<Directory> getApplicationDocumentsDirectory() async {
  return getFsApplicationDocumentsDirectory(fs);
}
