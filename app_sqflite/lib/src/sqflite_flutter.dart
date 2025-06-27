import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:sqflite/sqflite.dart' as sqflite show databaseFactory;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

String? buildDatabasesPath(String? packageName) {
  if (packageName == null) {
    return null;
  }
  var dataPath = join(userAppDataPath, packageName, 'databases');
  try {
    var dir = Directory(dataPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  } catch (_) {}
  return dataPath;
}

DatabaseFactory get _defaultDatabaseFactory =>
    (Platform.isLinux || Platform.isWindows)
    ? databaseFactoryFfi
    : sqflite.databaseFactory;

/// All but Linux/Windows
DatabaseFactory get databaseFactory => _defaultDatabaseFactory;

/// Use sqflite on any platform
Future<DatabaseFactory> initDatabaseFactory(String packageName) async {
  if (Platform.isLinux || Platform.isWindows) {
    var databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(buildDatabasesPath(packageName)!);
    return databaseFactory;
  } else {
    return databaseFactory;
  }
}

/// Use sqflite on any platform
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) {
  if (Platform.isLinux || Platform.isWindows) {
    var databaseFactory = databaseFactoryFfi;
    // Should not return a future...or ignore
    databaseFactory.setDatabasesPath(
      rootPath ?? buildDatabasesPath(packageName)!,
    );
    return databaseFactory;
  } else {
    return databaseFactory;
  }
}
