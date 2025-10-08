import 'package:tekartik_prefs_browser/prefs.dart';
import 'package:tekartik_prefs_browser/prefs_async.dart';

PrefsFactory get prefsFactory => prefsFactoryBrowser;

PrefsFactory getPrefsFactory({String? packageName}) => prefsFactory;

/// Browser prefs factory
PrefsAsyncFactory get prefsAsyncFactory => prefsAsyncFactoryBrowser;

/// Browser prefs factory
PrefsAsyncFactory getPrefsAsyncFactory({String? packageName}) =>
    prefsAsyncFactory;

/// Browser prefs factory
PrefsAsyncWithCacheFactory get prefsAsyncWithCacheFactory =>
    prefsAsyncWithCacheFactoryBrowser;

/// Browser prefs factory
PrefsAsyncWithCacheFactory getPrefsAsyncWithCacheFactory({
  String? packageName,
}) => prefsAsyncWithCacheFactory;
