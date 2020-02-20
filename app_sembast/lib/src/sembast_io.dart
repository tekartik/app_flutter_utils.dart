import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

/// All but Linux/Windows
DatabaseFactory get databaseFactory => databaseFactoryIo;

final _databaseFactoryMap = <String, DatabaseFactory>{};

DatabaseFactory newDatabaseFactorySembast(
    {String packageName, String rootPath}) {
  var dataPath =
      rootPath != null ? rootPath : join(userAppDataPath, packageName, 'db');
  return _newDatabaseFactorySembast(dataPath);
}

DatabaseFactory _newDatabaseFactorySembast(String dataPath) {
  try {
    Directory(dirname(dataPath)).createSync(recursive: true);
  } catch (_) {}
  return createDatabaseFactoryIo(rootPath: dataPath);
}

/// Use sembast on linux and windows
DatabaseFactory getDatabaseFactory({String packageName, String rootPath}) {
  if (rootPath != null) {
    var factory = _databaseFactoryMap[rootPath] ??=
        newDatabaseFactorySembast(rootPath: rootPath);
    return factory;
  } else if (packageName != null) {
    if (Platform.isLinux || Platform.isWindows) {
      var factory = _databaseFactoryMap[packageName] ??=
          newDatabaseFactorySembast(packageName: packageName);
      return factory;
    }
  }
  return databaseFactory;
}
