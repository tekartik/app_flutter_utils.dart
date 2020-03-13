import 'package:sqflite_common/sqlite_api.dart';

DatabaseFactory get databaseFactory => null;

Future<DatabaseFactory> getDatabaseFactory(String packageName) async => databaseFactory;
