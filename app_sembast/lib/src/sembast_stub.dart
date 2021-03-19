import 'package:sembast/sembast.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

DatabaseFactory getDatabaseFactory({String? packageName, String? rootPath}) =>
    _stub('getDatabaseFactory(packageName: $packageName, rootPath: $rootPath)');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
