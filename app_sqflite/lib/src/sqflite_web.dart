import 'package:sqflite_common/sqlite_api.dart';

DatabaseFactory get databaseFactory => _stub('databaseFactory');

Future<DatabaseFactory> initDatabaseFactory(String packageName) async =>
    databaseFactory;

DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    databaseFactory;

/// Only needed/implemented on windows
void sqfliteWindowsFfiInit() => _stub('sqfliteWindowsFfiInit');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
