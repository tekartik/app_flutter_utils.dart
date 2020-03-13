import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DatabaseFactory factory;
  setUpAll(() async {});

  test('databases path', () async {
    factory = databaseFactory;
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
  });

  test('init', () async {
    factory = await initDatabaseFactory('com.tekartik.dummy.app');
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
    expect(dummyDatabasesPath, contains('dummy.app'));
    print(dummyDatabasesPath);
    factory = await initDatabaseFactory(null);
    expect(await factory.getDatabasesPath(), isNotNull);
    expect(await factory.getDatabasesPath(), isNot(dummyDatabasesPath));
  });
}
