import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('prefs', () {
    //devPrint('MAIN_');
    item('open and toggle prefs', () async {
      var prefsFactory =
          getPrefsFactory(packageName: 'app_prefs_test_app.tekartik.com');
      var prefs = await prefsFactory.openPreferences('open_toggle_prefs');
      var toggle = prefs.getBool('toggle');
      toggle = !(toggle ?? false);
      prefs.setBool('toggle', toggle);
      await prefs.close();
      write('set toogle to $toggle');
      prefs = await prefsFactory.openPreferences('open_toggle_prefs');
      var newToggle = prefs.getBool('toggle');
      expect(newToggle, toggle);
    });
  });
}

void main() {
  platformInit();
  mainMenu(() {
    defineMenu();
  }, showConsole: true);
}
