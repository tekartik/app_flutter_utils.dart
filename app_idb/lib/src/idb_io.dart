import 'dart:io';

import 'package:idb_shim/idb_client_sembast.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:idb_sqflite/idb_client_sqflite.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tekartik_app_flutter_idb/idb.dart';

/// All but Linux/Windows
IdbFactory get idbFactory => idbFactorySqflite;

final _prefsFactoryMap = <String, IdbFactory>{};

String buildDatabasesPath(String packageName) {
  var dataPath = join(userAppDataPath, packageName, 'databases');
  try {
    var dir = Directory(dataPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  } catch (_) {}
  return dataPath;
}

IdbFactory newIdbFactorySembast(String packageName) {
  var dataPath = buildDatabasesPath(packageName);
  return IdbFactorySembast(databaseFactoryIo, dataPath);
}

/// Use sembast on linux and windows
IdbFactory getIdbFactory(String packageName) {
  if (Platform.isLinux || Platform.isWindows) {
    var idbFactory = _prefsFactoryMap[packageName];
    if (idbFactory == null) {
      _prefsFactoryMap[packageName] =
          idbFactory = newIdbFactorySembast(packageName);
    }
    return idbFactory;
  } else {
    return idbFactory;
  }
}
