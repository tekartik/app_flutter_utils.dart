import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;

import 'src/sembast.dart' as src;

export 'package:sembast/sembast.dart';

/// In memory factory.
DatabaseFactory get databaseFactoryMemory =>
    sembast_memory.databaseFactoryMemoryFs;

/// For all flutter app (including linux and windows).
///
/// For mobile/MacOS, sqflite is used, no parameter are needed,
///
/// On linux and windows, specify a package name or root path
///
/// On the web the parameters are ignored.
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);
