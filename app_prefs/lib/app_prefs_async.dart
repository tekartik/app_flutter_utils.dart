import 'package:tekartik_prefs/prefs_async.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs_async.dart';

/// The prefs factory to user
PrefsAsyncFactory get prefsAsyncFactory => src.prefsAsyncFactory;

/// Support Windows and Linux desktop
PrefsAsyncFactory getPrefsAsyncFactory({String? packageName}) =>
    src.getPrefsAsyncFactory(packageName: packageName);
