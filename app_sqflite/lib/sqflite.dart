import 'package:sqflite_common/sqlite_api.dart';

import 'src/sqflite.dart' as src;

export 'package:sqflite_common/sqlite_api.dart';

/// Default database factory: ffi (`databaseFactoryFfi` of
/// sqflite_common_ffi) on Android, iOS, macOS, Linux and Windows, ffi web on
/// the web.
///
/// Its databases path is the sqflite plugin folder on Android, iOS and macOS
/// (set before the first call), the one set by [getDatabaseFactory] on Linux
/// and Windows (the same object), the ffi default otherwise.
DatabaseFactory get databaseFactory => src.databaseFactory;

/// For all flutter app (including linux and windows)
///
/// [packageName] only used on linux and windows for now
@Deprecated('Use getDatabaseFactory()')
Future<DatabaseFactory> initDatabaseFactory(String packageName) =>
    src.initDatabaseFactory(packageName);

/// For all flutter app (including linux and windows): [databaseFactory].
///
/// [packageName] or [rootPath] only used on linux and windows for now,
/// [rootPath] also under flutter test on any platform: there the databases
/// path of that one shared factory becomes [rootPath], or
/// `<userAppDataPath>/<packageName>/databases` (created). Call it once, each
/// call changes it for every factory returned before.
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    src.getDatabaseFactory(packageName: packageName, rootPath: rootPath);

/// Only needed on Windows during development to find the proper dll location
/// (a no-op on the other io platforms, throws on the web).
void sqfliteWindowsFfiInit() => src.sqfliteWindowsFfiInit();
