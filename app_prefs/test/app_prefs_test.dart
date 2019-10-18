import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

void main() async {
  group('public', () {
    test('def', () {
      // ignore: unnecessary_statements
      Prefs;
      // ignore: unnecessary_statements
      PrefsFactory;
      prefsFactory;
      prefsFactoryMemory;
      print(prefsFactory.runtimeType);
    });
  });
}
