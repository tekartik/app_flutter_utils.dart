import 'package:sqflite_common/sqlite_api.dart';

DatabaseFactory get databaseFactory => null;

Future<DatabaseFactory> initDatabaseFactory(String packageName) async =>
    databaseFactory;

DatabaseFactory getDatabaseFactory({String packageName, String rootPath}) =>
    databaseFactory;