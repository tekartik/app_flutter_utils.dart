import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web factory is fined by default.
DatabaseFactory get databaseFactory => databaseFactoryFfiWeb;

Future<DatabaseFactory> initDatabaseFactory(String packageName) async =>
    databaseFactory;

DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    databaseFactory;

/// Only needed/implemented on windows
void sqfliteWindowsFfiInit() => _stub('sqfliteWindowsFfiInit');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
