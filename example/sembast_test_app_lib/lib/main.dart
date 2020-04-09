import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_flutter_sembast/setup/sembast_flutter.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('sembast', () {
    //devPrint('MAIN_');
    item('open and toggle value', () async {
      var prefsFactory =
          getDatabaseFactory(packageName: 'app_sembast_test_app.tekartik.com');
      var store = StoreRef<String, bool>.main();
      var prefs = await prefsFactory.openDatabase('open_toggle_sembast.db');
      var toggle = await store.record('toggle').get(prefs);
      toggle = !(toggle ?? false);
      await store.record('toggle').put(prefs, toggle);
      await prefs.close();
      write('set toogle to $toggle');
    });
  });
}

void main() {
  platformInit();
  mainMenu(() {}, showConsole: true);
}
