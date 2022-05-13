// ignore: depend_on_referenced_packages
import 'package:tekartik_prefs/prefs.dart';

import 'src/prefs.dart' as src;

// ignore: depend_on_referenced_packages
export 'package:tekartik_prefs/prefs.dart';

/// The prefs factory to user
PrefsFactory get prefsFactory => src.prefsFactory;

/// Support Windows and Linux desktop
PrefsFactory getPrefsFactory({String? packageName}) =>
    src.getPrefsFactory(packageName: packageName);
