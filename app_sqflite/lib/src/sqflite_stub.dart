import 'package:sqflite_common/sqlite_api.dart';

/// All but Linux/Windows
DatabaseFactory get databaseFactory => _stub('databaseFactory');

/// Use sqflite on any platform
Future<DatabaseFactory> initDatabaseFactory(String packageName) =>
    _stub('initDatabaseFactory($packageName)');

DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    _stub('getDatabaseFactory($packageName)');

/// Only needed/implemented on windows
void sqfliteWindowsFfiInit() => _stub('sqfliteWindowsFfiInit');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
