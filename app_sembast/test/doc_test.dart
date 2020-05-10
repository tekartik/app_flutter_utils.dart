import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

void main() {
  group('sembast', () {
    test('open', () async {
      ///
      var factory = getDatabaseFactory();

      var store = StoreRef<String, String>.main();
      await factory.deleteDatabase('test.db');
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
    test('open/close', () async {
      /// Using in memory implementation for unit test
      var factory = databaseFactoryMemory;
      var db = await factory.openDatabase('test.db');
      await db.close();
    });
  });
}
