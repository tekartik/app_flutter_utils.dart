import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_idb/idb.dart';

void main() {
  group('idb', () {
    test('factory', () {
      expect(idbFactory, isNotNull);
    });
    group('memory', () {
      test('open', () async {
        var factory = newIdbFactoryMemory();
        Future<Database> open() async {
          var db = await factory.open(
            'test.db',
            version: 1,
            onUpgradeNeeded: (e) {
              if (e.oldVersion < 1) {
                e.database.createObjectStore('simple');
              }
            },
          );
          return db;
        }

        var db = await open();
        var txn = db.transaction('simple', idbModeReadWrite);
        var store = txn.objectStore('simple');
        await store.put('test', 1);
        db.close();
        db = await open();
        txn = db.transaction('simple', idbModeReadOnly);
        store = txn.objectStore('simple');
        expect(await store.getObject(1), 'test');
        db.close();
      });
    });
  });
}
