import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_flutter_fs/fs.dart';

void main() {
  group('idb', () {
    test('factory', () {
      expect(fs, isNotNull);
    });
    test('getApplicationDocumentsDirectory()', () async {
      expect(
        (await fsMemory.getApplicationDocumentsDirectory(
          packageName: 'test.tekartik.com',
        )).path,
        '${context.separator}data',
      );
    });
    /*
    group('simple', () {
      test('open', () async {
        Future<Database> open() async {
          var db = await idbFactoryMemory.open('test.db', version: 1,
              onUpgradeNeeded: (e) {
            if (e.oldVersion < 1) {
              e.database.createObjectStore('simple');
            }
          });
          return db;
        }

        var db = await open();
        var txn = db.transaction('simple', idbModeReadWrite);
        var store = txn.objectStore('simple');
        store.put('test', 1);
        db.close();
        db = await open();
        txn = db.transaction('simple', idbModeReadOnly);
        store = txn.objectStore('simple');
        expect(await store.getObject(1), 'test');
        db.close();
      });
    });

     */
  });
}
