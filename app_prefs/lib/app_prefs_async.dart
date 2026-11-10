/// App preferences, the async `PrefsAsync` flavor (every read and write is
/// a `Future`): see `app_prefs.dart` for the platforms.
///
/// Re-exports `package:tekartik_prefs/prefs_async.dart`.
library;

import 'package:tekartik_prefs/prefs_async.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs_async.dart';

/// shared_preferences on io, local storage on the web. Prefer
/// [getPrefsAsyncFactory] (a sembast file on Linux and Windows).
PrefsAsyncFactory get prefsAsyncFactory => src.prefsAsyncFactory;

/// The async prefs factory of the app, a sembast file in
/// `<userAppDataPath>/<packageName>/prefs` on Linux and Windows,
/// [prefsAsyncFactory] elsewhere.
PrefsAsyncFactory getPrefsAsyncFactory({String? packageName}) =>
    src.getPrefsAsyncFactory(packageName: packageName);
