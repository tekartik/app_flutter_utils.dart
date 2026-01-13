import 'package:idb_shim/sdb.dart';

import 'idb.dart' as idb;

export 'package:idb_shim/sdb.dart';

/// The Sdb factory for your flutter application.
///
/// For mobile, it uses an sqflite base implementation, on the web,
/// it uses native implementation.
///
/// For testing you can use an in memory implementation for idb_shim.
SdbFactory get sdbFactory => sdbFactoryFromIdb(idb.idbFactory);

/// In memory factory.
SdbFactory get sdbFactoryMemory => sdbFactoryFromIdb(idb.idbFactoryMemory);

/// For all flutter app (including linux and windows)
///
/// Links with sembast though. Package name is only used for sembast
SdbFactory getSdbFactory({String? packageName}) =>
    sdbFactoryFromIdb(idb.getIdbFactory(packageName: packageName));
