import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_prefs/app_prefs.dart' as app_prefs;
import 'package:tekartik_prefs_flutter/prefs_mock.dart';

PrefsFactory get prefsFactory {
  // Special mac handling
  if (platformContext.io?.isMac ?? false) {
    return prefsFactoryMemory;
  } else {
    // Try regular, need to mock it first (just calling the constructor is enough).
    PrefsFactoryFlutterMock();
    return app_prefs.prefsFactory;
  }
}

PrefsFactory getPrefsFactory({String? packageName}) {
  // Special mack handling
  if (platformContext.io?.isMac ?? false) {
    return prefsFactoryMemory;
  } else {
    // Try regular
    return app_prefs.getPrefsFactory(packageName: packageName);
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('app_prefs', () {
    test('default', () async {
      var prefs = await prefsFactory.openPreferences('test_prefs.db');
      var value = prefs.getInt('value') ?? 0;
      prefs.setInt('value', ++value);
      // print('prefs set to $value');
      // Should increment at each test
    });
    test('doc', () async {
      // Get the default persistent prefs factory.
      var prefsFactory = getPrefsFactory();
      var prefs = await prefsFactory.openPreferences('my_shared_prefs');

      // Once you have a [Prefs] object ready, use it. You can keep it open.
      prefs.setInt('value', 26);
      var title = prefs.getString('title');

      {
        // For Windows/Linux support you can add package name to find a shared
        // location on the file system
        var prefsFactory = getPrefsFactory(packageName: 'my.package.name');

        expect(prefsFactory, isNotNull);
      }

      // Memory
      {
        // In memory prefs factory.
        var prefsFactory = newPrefsFactoryMemory();
        var prefs = await prefsFactory.openPreferences('test_prefs.db');
        expect(prefs.getInt('value'), isNull);
        prefs.setInt('value', 1);
        expect(prefs.getInt('value'), 1);
      }

      // ignore: unnecessary_statements
      title;
    });
  });
}
