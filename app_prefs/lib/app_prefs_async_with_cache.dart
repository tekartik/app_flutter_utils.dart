/// App preferences, the `PrefsAsyncWithCache` flavor (synchronous reads
/// from a cache, awaited writes): see `app_prefs.dart` for the platforms.
///
/// Re-exports `package:tekartik_prefs/prefs_async.dart`.
library;

import 'package:tekartik_prefs/prefs_async.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs_async.dart';

/// shared_preferences on io, local storage on the web. Prefer
/// [getPrefsAsyncWithCacheFactory] (a sembast file on Linux and Windows).
PrefsAsyncWithCacheFactory get prefsAsyncWithCacheFactory =>
    src.prefsAsyncWithCacheFactory;

/// The prefs factory of the app, a sembast file in
/// `<userAppDataPath>/<packageName>/prefs` on Linux and Windows,
/// [prefsAsyncWithCacheFactory] elsewhere.
PrefsAsyncWithCacheFactory getPrefsAsyncWithCacheFactory({
  String? packageName,
}) => src.getPrefsAsyncWithCacheFactory(packageName: packageName);
