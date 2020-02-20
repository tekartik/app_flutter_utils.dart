import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart' as sembast_memory;

import 'src/sembast.dart' as src;

export 'package:sembast/sembast.dart';

/// In memory factory.
DatabaseFactory get databaseFactoryMemory =>
    sembast_memory.databaseFactoryMemoryFs;

/// For all flutter app (including linux and windows).
///
/// For mobile/MacOS, use the rootPath, for example from path_provider,
///
/// On linux and windows, specify a package name.
///
/// On the web the parameters are ignored.
DatabaseFactory getDatabaseFactory({String packageName, String rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);
