import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite_dev.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tekartik_app_flutter_sembast/setup/sembast_sqflite.dart';

Future main() async {
  sqfliteFfiInit();
  // ignore: deprecated_member_use
  setMockDatabaseFactory(databaseFactoryFfi);
  group('sembast', () {
    test('factory', () async {
      var factory = databaseFactorySqflite;
      var db = await factory.openDatabase('test.db');

      await db.close();
    });
  });
}
