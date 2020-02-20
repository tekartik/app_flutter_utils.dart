import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
export 'package:sembast/sembast.dart';

/// Opinionated factory for flutter
///
/// (app_dir)/db on iOS/Android or when getApplicationDocumentsDirectory is supported
///
/// (app_data)/<package_name>/db on Desktop
///
/// IndexedDB db for the web
///
/// [packageName] only needed for desktop.
Future<DatabaseFactory> initDatabaseFactory({String packageName}) async {
  String rootPath;
// Common init for all
  if (!kIsWeb) {
    String documentsPath;
    try {
      documentsPath = (await getApplicationDocumentsDirectory()).path;
    } catch (_) {}
    if (documentsPath != null) {
      rootPath = join(documentsPath, 'db');
    }
  }
  var databaseFactory =
      getDatabaseFactory(rootPath: rootPath, packageName: packageName);
  return databaseFactory;
}
