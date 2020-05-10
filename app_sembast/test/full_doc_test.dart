import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

void main() {
  test('open/close', () async {
    /// Using in memory implementation for unit test
    var factory = databaseFactoryMemory;
    var db = await factory.openDatabase('test.db');
    // ...
    await db.close();
  });
}
