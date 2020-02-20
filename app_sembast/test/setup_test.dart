import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

void main() {
  var factory = getDatabaseFactory(
      rootPath: '.dart_tool/tekartik_app_flutter_sembast/db');
  group('sembast', () {
    test('factory', () {
      expect(getDatabaseFactory, isNotNull);
      expect(DatabaseFactory, isNotNull);
    });
    group('memory', () {
      test('open', () async {
        var store = StoreRef<String, String>.main();
        Future<Database> open() async {
          var db = await factory.openDatabase('test.db');
          return db;
        }

        var db = await open();
        await store.record('k').put(db, 'v');
        await db.close();
        db = await open();
        expect(await store.record('k').get(db), 'v');
        await db.close();
      });
    });
  });
}
