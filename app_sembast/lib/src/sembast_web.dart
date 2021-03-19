import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

/// Get Sembast Web context factory.
///
/// [packageName] and [rootPath] are ignored. The sembast database being
/// an indexed DB database.
DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    databaseFactoryWeb;
