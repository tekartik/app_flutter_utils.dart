import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

void main() async {
  group('app_prefs', () {
    test('default', () async {
      var prefs = await prefsFactory.openPreferences('test_prefs.db');
      var value = prefs.getInt('test.db') ?? 0;
      prefs.setInt('value', ++value);
      print('prefs set to $value');
    });
  });
}
