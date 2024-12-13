import 'package:tekartik_app_flutter_sembast/sembast.dart';

export 'package:sembast/sembast.dart';

/// Opinionated factory for flutter
///
/// (app_dir)/db on iOS/Android or when getApplicationDocumentsDirectory is supported
///
/// (app_data)/`<package_name>`/db on Desktop
///
/// IndexedDB db for the web
///
/// [packageName] only needed for desktop.
@Deprecated('User getDatabaseFactory instead')
Future<DatabaseFactory> initDatabaseFactory({String? packageName}) async {
  return getDatabaseFactory(packageName: packageName);
}
