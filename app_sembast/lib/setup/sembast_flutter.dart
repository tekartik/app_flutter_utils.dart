import 'package:tekartik_app_flutter_sembast/sembast.dart';

export 'package:sembast/sembast.dart';

/// Same as [getDatabaseFactory] (deprecated).
///
/// SQLite in the sqflite plugin databases folder on Android, iOS and macOS,
/// `<userAppDataPath>/<packageName>/databases` on Linux and Windows,
/// IndexedDB on the web.
///
/// [packageName] only needed for desktop.
@Deprecated('User getDatabaseFactory instead')
Future<DatabaseFactory> initDatabaseFactory({String? packageName}) async {
  return getDatabaseFactory(packageName: packageName);
}
