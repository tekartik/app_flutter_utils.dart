import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void defineMenu() {
  menu('prefs', () {
    var prefsFactory = getPrefsFactory(
      packageName: 'app_prefs_test_app.tekartik.com',
    );
    var prefsName = 'open_toggle_prefs';
    item('delete prefs', () async {
      await prefsFactory.deletePreferences(prefsName);
    });

    item('prefs toggle value', () async {
      var prefs = await prefsFactory.openPreferences(prefsName);
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
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
