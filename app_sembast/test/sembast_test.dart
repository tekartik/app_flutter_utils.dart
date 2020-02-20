import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/setup/sembast_flutter.dart';

Future main() async {
  var factory = await initDatabaseFactory(
      packageName: 'tekartik_app_sembast_flutter_test.tekartik.com');

  group('sembast', () {
    test('factory', () async {
      expect(await factory.openDatabase('test.db'), isNotNull);
      //expect(DatabaseFactory, isNotNull);
    });
    test('missing arg', () async {
      try {
        await initDatabaseFactory();
        fail('should fail');
      } on ArgumentError catch (_) {}
    });
  });
}
