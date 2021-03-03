import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart'
    show sqfliteWindowsFfiInit;

void main() {
  group('sembast', () {
    test('open', () async {
      sqfliteWindowsFfiInit();
      // Get the sembast database factory according to the current platform
      // * sembast_web for FlutterWeb and Web
      // * sembast_sqflite and sqflite on Flutter iOS/Android/MacOS
      // * sembast_sqflite and sqflite3 ffi on Flutter Windows/Linux and dart VM (might require extra initialization steps)
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
      var factory = newDatabaseFactoryMemory();
      var db = await factory.openDatabase('test.db');
      await db.close();
    });
  });
}
