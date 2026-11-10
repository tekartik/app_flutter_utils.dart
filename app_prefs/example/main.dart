// Counts the launches of the app in its prefs, on every platform
// (shared_preferences on Android, iOS and macOS, local storage on the web, a
// sembast file on Linux and Windows).
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

/// Increments and returns the launch count kept in the `settings` prefs.
Future<int> countLaunch(PrefsFactory factory) async {
  var prefs = await factory.openPreferences(
    'settings',
    version: 2,
    onVersionChanged: (prefs, oldVersion, newVersion) {
      if (oldVersion == 1) {
        // Version 1 named it 'count'.
        prefs.setInt('launches', prefs.getInt('count'));
        prefs.remove('count');
      }
    },
  );
  try {
    var launches = (prefs.getInt('launches') ?? 0) + 1;
    prefs.setInt('launches', launches);
    // Saved in the background, force it before closing.
    await prefs.save();
    return launches;
  } finally {
    await prefs.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once: packageName is the prefs folder on Linux and Windows. Tests pass
  // newPrefsFactoryMemory() to countLaunch instead.
  var factory = getPrefsFactory(packageName: 'com.tekartik.app_prefs_example');
  var launches = await countLaunch(factory);
  runApp(
    Center(
      child: Text(
        'Launch #$launches',
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );
}
