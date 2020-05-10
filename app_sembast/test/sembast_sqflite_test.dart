import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tekartik_app_flutter_sembast/setup/sembast_sqflite_ffi.dart';

Future main() async {
  sqfliteFfiInit();
  group('sembast', () {
    test('factory', () async {
      var factory = databaseFactorySqfliteFfi;
      var db = await factory.openDatabase('test.db');

      await db.close();
    });
  });
}
