/// sdb (the typed API of idb_shim) factories for a Flutter app on every
/// platform, on the factories of `idb.dart`: SQLite (ffi) on Android, iOS,
/// macOS, Linux and Windows, the browser IndexedDB on the web.
///
/// Re-exports `package:idb_shim/sdb.dart`.
library;

import 'package:idb_shim/sdb.dart';

import 'idb.dart' as idb;

export 'package:idb_shim/sdb.dart';

/// The Sdb factory for your flutter application.
///
/// SQLite (ffi) on Android, iOS and macOS, the browser IndexedDB on the web.
/// On Linux and Windows use [getSdbFactory] with a package name.
///
/// For testing you can use an in memory implementation for idb_shim.
SdbFactory get sdbFactory => sdbFactoryFromIdb(idb.idbFactory);

/// In memory factory.
SdbFactory get sdbFactoryMemory => sdbFactoryFromIdb(idb.idbFactoryMemory);

/// For all flutter app (including linux and windows): see
/// `getIdbFactory` of `idb.dart` for the Linux and Windows folder (call it
/// once, with a package name).
SdbFactory getSdbFactory({String? packageName}) =>
    sdbFactoryFromIdb(idb.getIdbFactory(packageName: packageName));
