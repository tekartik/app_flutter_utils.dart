import 'package:tekartik_app_flutter_fs/fs.dart';

/// Get the application file system
FileSystem get fs => _stub('fs');

/// Get the application file system
FileSystem get testFs => _stub('testFs');

/// Get the application file system
Future<Directory> getApplicationDocumentsDirectory({String? packageName}) =>
    _stub('getApplicationDocumentsDirectory');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
