/// IndexedDB (idb_shim) factories for a Flutter app on every platform:
/// SQLite (idb_sqflite over tekartik_app_flutter_sqflite, ffi) on Android,
/// iOS, macOS, Linux and Windows, the browser IndexedDB on the web.
///
/// Re-exports `package:idb_shim/idb_shim.dart`. For new code prefer the
/// typed sdb API on the same factory: `sdb.dart`.
library;

import 'package:idb_shim/idb_client.dart';
import 'package:idb_shim/idb_client_memory.dart' as idb_shim_memory;

import 'src/idb.dart' as src;

export 'package:idb_shim/idb_shim.dart';

/// The Idb factory for your flutter application.
///
/// SQLite (ffi) on Android, iOS and macOS, in the sqflite plugin databases
/// folder; the browser IndexedDB on the web. On Linux and Windows it keeps
/// the ffi default folder: use [getIdbFactory] with a package name there.
///
/// For testing you can use an in memory implementation for idb_shim.
IdbFactory get idbFactory => src.idbFactory;

/// In memory factory.
IdbFactory get idbFactoryMemory => idb_shim_memory.idbFactoryMemory;

/// For all flutter app (including linux and windows): [idbFactory], with on
/// Linux and Windows the databases in
/// `<userAppDataPath>/<packageName>/databases` (`<userAppDataPath>/databases`,
/// shared by every app, without [packageName]).
///
/// On Linux and Windows that folder is the one of a single shared sqflite
/// factory: call it once, another package name (or a `getDatabaseFactory`
/// of tekartik_app_flutter_sqflite / tekartik_app_flutter_sembast) moves the
/// databases of every factory returned before. [packageName] is ignored on
/// the other platforms.
IdbFactory getIdbFactory({String? packageName}) =>
    src.getIdbFactory(packageName: packageName);
