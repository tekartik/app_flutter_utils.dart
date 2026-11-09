// Counts the launches of the app in a sqflite database, on every platform
// (run `dart run sqflite_common_ffi_web:setup` once for the web).
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

/// Increments and returns the launch count kept in the database.
Future<int> countLaunch(DatabaseFactory factory) async {
  var db = await factory.openDatabase(
    'example.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Pref (id TEXT PRIMARY KEY, value INTEGER NOT NULL)',
        );
      },
    ),
  );
  try {
    return await db.transaction((txn) async {
      var rows = await txn.query(
        'Pref',
        where: 'id = ?',
        whereArgs: ['launches'],
      );
      var count = rows.isEmpty ? 1 : (rows.first['value'] as int) + 1;
      await txn.insert('Pref', {
        'id': 'launches',
        'value': count,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return count;
    });
  } finally {
    await db.close();
  }
}

Future<void> main() async {
  // path_provider (databases folder on Android, iOS, macOS) needs it.
  WidgetsFlutterBinding.ensureInitialized();
  // packageName: the databases folder on Linux and Windows.
  var factory = getDatabaseFactory(packageName: 'com.tekartik.app_sqflite');
  var count = await countLaunch(factory);
  runApp(
    Center(
      child: Text(
        'Launch #$count',
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );
}
