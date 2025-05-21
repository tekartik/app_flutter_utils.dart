@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:tekartik_app_flutter_idb/idb.dart';
import 'package:tekartik_app_flutter_idb/src/idb_io.dart';

var objectStoreName = 'test';

void main() {
  // needed on windows
  sqflite_ffi.sqfliteFfiInit();
  for (var factory in [
    newIdbFactorySembast(
      dataPath: join('.dart_tool', 'app_idb_test_databases'),
    ),
    newIdbFactorySqflite(),
  ]) {
    //var factory = newIdbFactorySqflite(); // databaseFactoryFfiNoIsolate;
    group('simple idb sqflite idb factory', () {
      Future<void> testInsert(Database db, {int count = 100000}) async {
        var txn = db.transaction(objectStoreName, idbModeReadWrite);
        var os = txn.objectStore(objectStoreName);
        for (var i = 0; i < count; i++) {
          await os.add({'intValue': i + 1});
        }
      }

      Future<void> testQuery(Database db, {int count = 100000}) async {
        var txn = db.transaction(objectStoreName, idbModeReadOnly);
        var os = txn.objectStore(objectStoreName);
        var cursor = os.openCursor(autoAdvance: true);
        var result = await cursor.toList();
        expect(result.length, count);
      }

      Future<void> testAll(IdbFactory factory, {int count = 100000}) async {
        var dbName = 'app_idb_test1.db';
        await factory.deleteDatabase(dbName);
        var db = await factory.open(
          'app_idb_test1.db',
          version: 1,
          onUpgradeNeeded: (vce) {
            var db = vce.database;
            db.createObjectStore(objectStoreName, autoIncrement: true);
          },
        );
        await testInsert(db, count: count);
        await testQuery(db, count: count);
        db.close();
      }

      test('10 queries', () async {
        await testAll(factory, count: 10);
      });
    });
  }
}
