/// App preferences for a Flutter app on every platform, the sync `Prefs`
/// flavor: shared_preferences on Android, iOS and macOS, local storage on
/// the web, a sembast file on Linux and Windows ([getPrefsFactory]).
///
/// Re-exports `package:tekartik_prefs/prefs.dart`.
library;

// ignore: depend_on_referenced_packages
import 'package:tekartik_prefs/prefs.dart';

import 'src/prefs.dart' as src;

// ignore: depend_on_referenced_packages
export 'package:tekartik_prefs/prefs.dart';

/// shared_preferences on Android, iOS, macOS, Linux and Windows, local
/// storage on the web.
///
/// Prefer [getPrefsFactory]: on Linux and Windows it is another storage (a
/// sembast file), mixing both reads empty prefs.
PrefsFactory get prefsFactory => src.prefsFactory;

/// The prefs factory of the app: [prefsFactory] on Android, iOS, macOS and
/// the web, a sembast file in `<userAppDataPath>/<packageName>/prefs` on
/// Linux and Windows (`<userAppDataPath>/com.tekartik.app_prefs/prefs`,
/// shared by every app, without [packageName]). Cached per package name.
PrefsFactory getPrefsFactory({String? packageName}) =>
    src.getPrefsFactory(packageName: packageName);
