import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart'
    show sqfliteWindowsFfiInit;

Future main() async {
  sqfliteWindowsFfiInit();
  var factory = getDatabaseFactory(
    packageName: 'tekartik_app_sembast_flutter_test.tekartik.com',
  );

  group('sembast', () {
    test('factory', () async {
      expect(await factory.openDatabase('test.db'), isNotNull);
    });
  });
}
