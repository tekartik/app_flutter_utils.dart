import 'package:sembast_sqflite/sembast_sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

export 'package:sembast/sembast.dart';

/// Sembast sqflite ffi based database factory.
///
/// Supports Windows/Linux/MacOS for now.
final databaseFactorySqfliteFfi = getDatabaseFactorySqflite(
  sqflite_ffi.databaseFactoryFfi,
);
