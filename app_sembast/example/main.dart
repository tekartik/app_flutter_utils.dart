// Counts the launches of the app in a sembast database, on every platform
// (SQLite on Android, iOS, macOS, Linux and Windows, IndexedDB on the web).
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

/// key: the counter name, value: its count.
final counterStore = StoreRef<String, int>('counter');

/// Increments and returns the launch count kept in [db].
Future<int> countLaunch(Database db) async {
  return await db.transaction((txn) async {
    var record = counterStore.record('launches');
    var count = (await record.get(txn) ?? 0) + 1;
    await record.put(txn, count);
    return count;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once: packageName is the databases folder on Linux and Windows.
  var factory = getDatabaseFactory(packageName: 'com.tekartik.app_sembast');
  // Open once, keep it open.
  var db = await factory.openDatabase('example.db');
  var count = await countLaunch(db);
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
