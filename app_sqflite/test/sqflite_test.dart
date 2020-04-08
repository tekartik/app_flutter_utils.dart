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
    // ignore: deprecated_member_use_from_same_package
    factory = await initDatabaseFactory('com.tekartik.dummy.app');
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
    expect(dummyDatabasesPath, contains('dummy.app'));
    print(dummyDatabasesPath);
    // ignore: deprecated_member_use_from_same_package
    factory = await initDatabaseFactory(null);
    expect(await factory.getDatabasesPath(), isNotNull);
    expect(await factory.getDatabasesPath(), isNot(dummyDatabasesPath));
  });

  test('get', () async {
    factory = getDatabaseFactory('com.tekartik.dummy.app');
    var dummyDatabasesPath = await factory.getDatabasesPath();
    expect(dummyDatabasesPath, isNotNull);
    expect(dummyDatabasesPath, contains('dummy.app'));
    print(dummyDatabasesPath);
    factory = getDatabaseFactory(null);
    expect(await factory.getDatabasesPath(), isNotNull);
    expect(await factory.getDatabasesPath(), isNot(dummyDatabasesPath));
  });
}
