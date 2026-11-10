/// A sembast database factory for a Flutter app on every platform: sembast
/// on SQLite (sembast_sqflite over tekartik_app_flutter_sqflite, ffi) on
/// Android, iOS, macOS, Linux and Windows, sembast_web (IndexedDB) on the
/// web.
///
/// Re-exports `package:sembast/sembast.dart`.
library;

import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;

import 'src/sembast.dart' as src;

export 'package:sembast/sembast.dart';

/// In memory factory.
DatabaseFactory get databaseFactoryMemory =>
    sembast_memory.databaseFactoryMemoryFs;

/// For all flutter app (including linux and windows).
///
/// On Android, iOS and macOS: SQLite in the sqflite plugin databases folder,
/// the parameters are ignored.
///
/// On Linux and Windows: the databases are in
/// `<userAppDataPath>/<packageName>/databases`, or in [rootPath]
/// (`<userAppDataPath>/databases`, shared by every app, without either).
/// That folder is the one of a single shared sqflite factory: call it once,
/// a later call with another [packageName] or [rootPath] moves the
/// databases of every factory returned before.
///
/// Under flutter test, root path is used on any platform.
///
/// On the web the parameters are ignored.
///
/// Each call builds a new sembast factory: keep the one you get (two
/// factories opening the same file are two databases with their own cache).
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);
