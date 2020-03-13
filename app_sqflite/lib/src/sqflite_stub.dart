import 'package:sqflite_common/sqlite_api.dart';

/// All but Linux/Windows
DatabaseFactory get databaseFactory => _stub('databaseFactory');

/// Use sqflite on any platform
Future<DatabaseFactory> initDatabaseFactory(String packageName) =>
    _stub('initDatabaseFactory($packageName)');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
