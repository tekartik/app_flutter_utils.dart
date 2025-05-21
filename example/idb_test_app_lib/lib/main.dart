import 'package:tekartik_app_flutter_idb/idb.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('idb', () {
    var idbFactory = getIdbFactory(
      packageName: 'app_idb_test_app.tekartik.com',
    );
    var dbName = 'open_toggle_idb.db';
    item('delete database', () async {
      await idbFactory.deleteDatabase(dbName);
    });
    item('open and toggle value', () async {
      var db = await idbFactory.open(
        dbName,
        version: 1,
        onUpgradeNeeded: (event) {
          var db = event.database;
          db.createObjectStore('main');
        },
      );
      var toggle =
          await db
                  .transaction('main', idbModeReadOnly)
                  .objectStore('main')
                  .getObject('toggle')
              as bool?;
      toggle = !(toggle ?? false);
      await db
          .transaction('main', idbModeReadWrite)
          .objectStore('main')
          .put(toggle, 'toggle');
      db.close();
      write('set toogle to $toggle');
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {}, showConsole: true);
}
