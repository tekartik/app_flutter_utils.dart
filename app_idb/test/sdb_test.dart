import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';

var simpleStore = SdbStoreRef<int, String>('simple');
void main() {
  group('sdb', () {
    test('factory', () {
      expect(sdbFactory, isNotNull);
    });
    group('memory', () {
      test('open', () async {
        var factory = newSdbFactoryMemory();
        Future<SdbDatabase> open() async {
          var db = await factory.openDatabase(
            'test.db',
            version: 1,
            onVersionChange: (e) {
              if (e.oldVersion < 1) {
                e.db.createStore(simpleStore);
              }
            },
          );
          return db;
        }

        var db = await open();
        await simpleStore.record(1).put(db, 'test');

        var readValue = await simpleStore.record(1).getValue(db);
        expect(readValue, 'test');
        await db.close();
      });
    });
  });
}
