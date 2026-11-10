// Counts the launches of the app in an sdb database, on every platform
// (SQLite on Android, iOS, macOS, Linux and Windows, IndexedDB on the web).
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';

/// key: the counter name, value: its count.
final counterStore = SdbStoreRef<String, int>('counter');

/// Increments and returns the launch count kept in the database.
Future<int> countLaunch(SdbFactory factory) async {
  var db = await factory.openDatabase(
    'example.db',
    options: SdbOpenDatabaseOptions(
      version: 1,
      onVersionChange: (event) {
        if (event.oldVersion < 1) {
          event.db.createStore(counterStore);
        }
      },
    ),
  );
  try {
    var record = counterStore.record('launches');
    var count = (await record.getValue(db) ?? 0) + 1;
    await record.put(db, count);
    return count;
  } finally {
    await db.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // packageName: the databases folder on Linux and Windows.
  var factory = getSdbFactory(packageName: 'com.tekartik.app_idb');
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
