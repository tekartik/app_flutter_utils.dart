import 'package:idb_shim/idb_client.dart';
import 'package:idb_shim/idb_client_memory.dart' as idb_shim_memory;

import 'src/idb.dart' as src;

export 'package:idb_shim/idb_shim.dart';

/// The Idb factory for your flutter application.
///
/// For mobile, it uses an sqflite base implementation, on the web,
/// it uses native implementation.
///
/// For testing you can use an in memory implementation for idb_shim.
IdbFactory get idbFactory => src.idbFactory;

/// In memory factory.
IdbFactory get idbFactoryMemory => idb_shim_memory.idbFactoryMemory;

/// For all flutter app (including linux and windows)
///
/// Links with sembast though. Package name is only used for sembast
IdbFactory getIdbFactory({String? packageName}) =>
    src.getIdbFactory(packageName: packageName);
