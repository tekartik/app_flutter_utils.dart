import 'package:sqflite_common/sqlite_api.dart';

DatabaseFactory get databaseFactory => null;

Future<DatabaseFactory> initDatabaseFactory(String packageName) async =>
    databaseFactory;
