import 'package:tekartik_prefs/prefs.dart';

import 'src/prefs.dart' as src;

export 'package:tekartik_prefs/prefs.dart';

/// The prefs factory to user
PrefsFactory get prefsFactory => src.prefsFactory;

/// Support Windows and Linux desktop
PrefsFactory getPrefsFactory({String? packageName}) =>
    src.getPrefsFactory(packageName: packageName);
