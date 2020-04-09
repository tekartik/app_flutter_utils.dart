import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart' as sqflite;

/*
/// All but Linux/Windows
DatabaseFactory get databaseFactory => databaseFactoryIo;

final _databaseFactoryMap = <String, DatabaseFactory>{};

DatabaseFactory newDatabaseFactorySembastIo(
    {String packageName, String rootPath}) {
  var dataPath = rootPath ?? join(userAppDataPath, packageName, 'db');
  return _newDatabaseFactorySembastIo(dataPath);
}

DatabaseFactory _newDatabaseFactorySembastIo(String dataPath) {
  try {
    Directory(dirname(dataPath)).createSync(recursive: true);
  } catch (_) {}
  return createDatabaseFactoryIo(rootPath: dataPath);
}
*/

/// Use app data on linux and windows if rootPath is null
///
/// Throw if no path defined
DatabaseFactory getDatabaseFactory({String packageName, String rootPath}) =>
    getDatabaseFactorySqflite(sqflite.getDatabaseFactory(
        packageName: packageName, rootPath: rootPath));
