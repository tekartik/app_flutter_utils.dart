import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

Future main() async {
  var factory = getDatabaseFactory(
      packageName: 'tekartik_app_sembast_flutter_test.tekartik.com');

  group('sembast', () {
    test('factory', () async {
      expect(await factory.openDatabase('test.db'), isNotNull);
    });
  });
}
