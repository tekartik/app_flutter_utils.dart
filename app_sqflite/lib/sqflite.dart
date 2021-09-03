import 'package:sqflite_common/sqlite_api.dart';

import 'src/sqflite.dart' as src;

export 'package:sqflite_common/sqlite_api.dart';

/// Default database factory, uses ffi on Windows and Linux
DatabaseFactory get databaseFactory => src.databaseFactory;

/// For all flutter app (including linux and windows)
///
/// [packageName] only used on linux and windows for now
@Deprecated('Use getDatabaseFactory()')
Future<DatabaseFactory> initDatabaseFactory(String packageName) =>
    src.initDatabaseFactory(packageName);

/// For all flutter app (including linux and windows)
///
/// [packageName] or [rootPath] only used on linux and windows for now
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);

/// Only needed on Windows during development to find the proper dll location
void sqfliteWindowsFfiInit() => src.sqfliteWindowsFfiInit();
