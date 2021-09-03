import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

void main() async {
  group('getPrefsFactory', () {
    test('def', () {
      // ignore: unnecessary_statements
      Prefs;
      // ignore: unnecessary_statements
      PrefsFactory;
      // ignore: unnecessary_statements
      getPrefsFactory;
      prefsFactory;
      prefsFactoryMemory;
      print(prefsFactory.runtimeType); // ignore: avoid_print
    });
  });
}
