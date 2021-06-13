import 'package:sqflite_common/sqlite_api.dart';
// ignore: implementation_imports
import 'package:sqflite_common/src/mixin/import_mixin.dart'
    show SqfliteDatabaseFactoryMixin;

// Temp direct call needed when nndb ready
extension DatabasesFactorySetDatabasesPathExt on DatabaseFactory {
  Future<void> compatSetDatabasesPath(String path) {
    return (this as SqfliteDatabaseFactoryMixin).setDatabasesPath(path);
  }
}
