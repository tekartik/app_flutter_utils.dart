import 'package:tekartik_app_prefs/app_prefs_async.dart';

import 'import.dart';

PrefsFactory get prefsFactory => _stub('prefsFactory');

/// Stub
PrefsAsyncFactory get prefsAsyncFactory => _stub('prefsAsyncFactory');

/// Stub
PrefsFactory getPrefsFactory({String? packageName}) => _stub('getPrefsFactory');

/// Stub
PrefsAsyncFactory getPrefsAsyncFactory({String? packageName}) =>
    _stub('getPrefsAsyncFactory');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
