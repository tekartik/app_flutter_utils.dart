import 'package:tekartik_prefs/prefs_async.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs_async.dart';

/// The prefs factory to use
PrefsAsyncWithCacheFactory get prefsAsyncWithCacheFactory =>
    src.prefsAsyncWithCacheFactory;

/// Support Windows and Linux desktop
PrefsAsyncWithCacheFactory getPrefsAsyncWithCacheFactory({
  String? packageName,
}) => src.getPrefsAsyncWithCacheFactory(packageName: packageName);
