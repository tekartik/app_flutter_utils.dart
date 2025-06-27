import 'dart:io';

import 'package:idb_shim/idb_client_sembast.dart';
import 'package:idb_sqflite/idb_client_sqflite.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sembast/sembast_io.dart' as sembast;
import 'package:tekartik_app_flutter_sqflite/sqflite.dart' as sqflite;

/// All but Linux/Windows
IdbFactory get idbFactory => getIdbFactorySqflite(sqflite.databaseFactory);

final _prefsFactoryMap = <String?, IdbFactory>{};

String buildDatabasesPath({required String packageName}) {
  var dataPath = join(userAppDataPath, packageName, 'databases');
  try {
    var dir = Directory(dataPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  } catch (_) {}
  return dataPath;
}

IdbFactory newIdbFactorySembast({String? packageName, String? dataPath}) {
  if (dataPath == null) {
    if (packageName != null) {
      dataPath = buildDatabasesPath(packageName: packageName);
    }
  }
  return IdbFactorySembast(sembast.databaseFactoryIo, dataPath);
}

IdbFactory newIdbFactorySqflite({String? packageName}) {
  return getIdbFactorySqflite(
    sqflite.getDatabaseFactory(packageName: packageName),
  );
}

/// Use sqflite_ffi on linux and windows
IdbFactory getIdbFactory({String? packageName}) {
  if (Platform.isLinux || Platform.isWindows) {
    IdbFactory? idbFactory;
    if (packageName != null) {
      idbFactory = _prefsFactoryMap[packageName];
    }
    if (idbFactory == null) {
      _prefsFactoryMap[packageName] = idbFactory = newIdbFactorySqflite(
        packageName: packageName,
      );
    }
    return idbFactory;
  } else {
    return idbFactory;
  }
}
