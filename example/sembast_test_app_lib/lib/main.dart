import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('sembast', () {
    var sembastFactory = getDatabaseFactory(
      packageName: 'app_sembast_test_app.tekartik.com',
    );
    var dbName = 'open_toggle_sembast.db';
    item('delete database', () async {
      await sembastFactory.deleteDatabase(dbName);
    });
    item('open and toggle value', () async {
      var store = StoreRef<String, bool>.main();
      var prefs = await sembastFactory.openDatabase(dbName);
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
  mainMenuFlutter(() {}, showConsole: true);
}
