import 'import.dart';

PrefsFactory get prefsFactory => _stub('prefsFactory');

PrefsFactory getPrefsFactory({String? packageName}) => _stub('getPrefsFactory');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
