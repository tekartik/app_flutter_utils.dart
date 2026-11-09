import 'package:idb_shim/sdb.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_sdb_ui_flutter/sdb_ui_flutter.dart';

// The widgets are built with package:material_ui (the material library
// published outside the Flutter SDK): the app uses its MaterialApp too.

/// The store listed: int keys, map values.
final noteStore = SdbStoreRef<int, SdbModel>('note');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // In memory here; an app opens it with sdbFactoryWeb (web) or
  // sdbFactorySqflite (idb_sqflite, mobile and desktop).
  var db = await sdbFactoryMemory.openDatabase(
    'notes.db',
    options: SdbOpenDatabaseOptions(
      version: 1,
      schema: SdbDatabaseSchema(
        stores: [noteStore.schema(autoIncrement: true)],
      ),
    ),
  );
  runApp(MaterialApp(home: NotesPage(db: db)));
}

class NotesPage extends StatelessWidget {
  final SdbDatabase db;

  const NotesPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      // Loads the notes page by page; watch: true follows the writes.
      body: SdbStoreListView<int, SdbModel>(
        client: db,
        store: noteStore,
        watch: true,
        itemExtent: 56,
        itemBuilder: (context, snapshot, index) => ListTile(
          title: Text('${snapshot.value['text']}'),
          onTap: () => noteStore.record(snapshot.key).delete(db),
        ),
        emptyBuilder: (context) => const Center(child: Text('No note')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => noteStore.add(db, {
          'text': 'Note ${DateTime.now().toIso8601String()}',
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
