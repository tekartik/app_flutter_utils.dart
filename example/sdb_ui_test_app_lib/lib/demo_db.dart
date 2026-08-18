import 'dart:async';
import 'dart:math';

import 'package:tekartik_app_flutter_idb/sdb.dart';

/// Demo record: `{'name': ..., 'category': ..., 'value': ...}`.
final noteStore = SdbStoreRef<int, SdbModel>('note');

/// Index on the note name.
final noteNameIndex = noteStore.index<String>('name');

/// Package name used for the underlying sembast/sqflite database.
const demoPackageName = 'app_sdb_ui_test_app.tekartik.com';

/// Demo database name.
const demoDbName = 'sdb_ui_demo.db';

/// Categories used by the filtered demos.
const demoCategories = ['alpha', 'beta', 'gamma', 'delta'];

/// The demo database, opened once and populated on demand.
class DemoDb {
  DemoDb._();

  /// Singleton, the database is shared by every demo page.
  static final instance = DemoDb._();

  final _factory = getSdbFactory(packageName: demoPackageName);
  final _random = Random();
  SdbDatabase? _db;
  Timer? _writerTimer;

  /// Open (and create the schema if needed).
  Future<SdbDatabase> openDatabase() async {
    return _db ??= await _factory.openDatabase(
      demoDbName,
      options: SdbOpenDatabaseOptions(
        version: 1,
        schema: SdbDatabaseSchema(
          stores: [
            noteStore.schema(
              autoIncrement: true,
              indexes: [noteNameIndex.schema(keyPath: 'name')],
            ),
          ],
        ),
      ),
    );
  }

  /// Current record count.
  Future<int> getCount() async => noteStore.count(await openDatabase());

  /// Add [count] records, in chunks to keep the transactions small.
  Future<void> populate(int count) async {
    var db = await openDatabase();
    var existing = await noteStore.count(db);
    const chunkSize = 500;
    for (var offset = 0; offset < count; offset += chunkSize) {
      var chunk = min(chunkSize, count - offset);
      await db.inStoreTransaction(noteStore, SdbTransactionMode.readWrite, (
        txn,
      ) async {
        for (var i = 0; i < chunk; i++) {
          var index = existing + offset + i;
          await noteStore.add(txn, _newNote(index));
        }
      });
    }
  }

  SdbModel _newNote(int index) => {
    'name': 'Note ${(index + 1).toString().padLeft(6, '0')}',
    'category': demoCategories[index % demoCategories.length],
    'value': index,
  };

  /// Delete every record.
  Future<void> clear() async {
    var db = await openDatabase();
    await noteStore.delete(db);
  }

  /// Delete the whole database.
  Future<void> deleteDatabase() async {
    stopWriter();
    await _db?.close();
    _db = null;
    await _factory.deleteDatabase(demoDbName);
  }

  /// Modify one random record, mimicking an app writing in the background.
  Future<void> writeOne() async {
    var db = await openDatabase();
    var count = await noteStore.count(db);
    if (count == 0) {
      return;
    }
    var records = await noteStore.findRecords(
      db,
      options: SdbFindOptions(offset: _random.nextInt(count), limit: 1),
    );
    if (records.isEmpty) {
      return;
    }
    var record = records.first;
    await record.ref.put(db, {
      ...record.value,
      'value': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// True while the background writer is running.
  bool get isWriting => _writerTimer != null;

  /// Start/stop a background writer, one record modified every 500ms.
  void toggleWriter() {
    if (_writerTimer != null) {
      stopWriter();
      return;
    }
    _writerTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => unawaited(writeOne()),
    );
  }

  /// Stop the background writer.
  void stopWriter() {
    _writerTimer?.cancel();
    _writerTimer = null;
  }
}
