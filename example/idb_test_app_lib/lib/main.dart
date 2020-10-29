import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_flutter_idb/idb.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('idb', () {
    //devPrint('MAIN_');
    item('open and toggle value', () async {
      var prefsFactory =
          getIdbFactory(packageName: 'app_idb_test_app.tekartik.com');
      var prefs = await prefsFactory.open('open_toggle_idb.db', version: 1,
          onUpgradeNeeded: (event) {
        var db = event.database;
        db.createObjectStore('main');
      });
      var toggle = await prefs
          .transaction('main', idbModeReadOnly)
          .objectStore('main')
          .getObject('toggle') as bool;
      toggle = !(toggle ?? false);
      await prefs
          .transaction('main', idbModeReadWrite)
          .objectStore('main')
          .put(toggle, 'toggle');
      prefs.close();
      write('set toogle to $toggle');
    });
  });
}

void main() {
  platformInit();
  mainMenu(() {}, showConsole: true);
}
