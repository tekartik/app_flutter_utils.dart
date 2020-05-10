import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

export 'package:sembast/sembast.dart';

/// Sembast sqflite based database factory.
///
/// Supports iOS/Android/MacOS for now.
final databaseFactorySqflite =
    getDatabaseFactorySqflite(sqflite.databaseFactory);
